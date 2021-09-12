using System.Collections;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using UnityEngine;


[RequireComponent(typeof(Camera))]
public class HalftoneController : MonoBehaviour
{
    const int visibilityDipstach = 256;

    [StructLayout(LayoutKind.Sequential)]
    struct halftonePoint
    {
        public const int stride =
            sizeof(float) * 2 +
            sizeof(float);

        public Vector2 screenPos;
        public float density;
    }
    public ComputeShader pointsVisibilityCalculator;
    public ComputeShader pointsAtributesCalculator;


    public float particleSizeMultipiler = 1.0f;


    public Shader particlesShader;
    public Texture2D particleTex;
    [System.NonSerialized]
    private Material cyanMat, magentaMat, yellowMat, blackMat;
    private Vector2 aspectVector = Vector2.one;

    int kernelCyanVisCalCs, kernelMagentaVisCalCs, kernelYellowVisCalCs, kernelBlackVisCalCs;
    int kernelCyanAtributeCalCs, kernelMagentaAtributeCalCs, kernelYellowAtributeCalCs, kernelBlackAtributeCalCs;
    int numberOfCyanPoints, numberOfMagentaPoints, numberOfYellowPoints, numberOfBlackPoints;
    int blurHorID, blurVerID;

    RenderTexture verBlurOutput, horBlurOutput, tempSource = null;

    [Range(3, 64)]
    public int distanceBeetwenPoints = 3;

    private int _distanceBeetwenPoints;


    [Range(0.1f, 0.9f)]
    public float cyanEfficency;
    [Range(0.1f, 0.9f)]
    public float magentaEfficency;
    [Range(0.1f, 0.9f)]
    public float yellowEfficency;
    [Range(0.1f, 0.9f)]
    public float blackEfficency;

    [Range(-90.0f, 90.0f)]
    public float cyanAngle;
    [Range(-90.0f, 90.0f)]
    public float magentaAngle;
    [Range(-90.0f, 90.0f)]
    public float yellowAngle;
    [Range(-90.0f, 90.0f)]
    public float blackAngle;

    Camera thisCamera;


    int resolutionX = 0;
    int resolutionY = 0;
    int gridResolutionX;
    int gridResolutionY;
    int resolution;
    int maxEdge;

    Vector2 particleScreenSize;

    ComputeBuffer allCyanPoints, allMagentaPoints, allYellowPoints, allBlackPoints;
    ComputeBuffer visibleCyanPoints, visibleMagentaPoints, visibleYellowPoints, visibleBlackPoints;
    ComputeBuffer drawIndirectCyan, drawIndirectMagenta, drawIndirectYellow, drawIndirectBlack;

    private bool init = false;


    public Vector2 Rotate(Vector2 vectorToRotate, float degrees)
    {
        Vector2 v = vectorToRotate;
        float sin = Mathf.Sin(degrees * Mathf.Deg2Rad);
        float cos = Mathf.Cos(degrees * Mathf.Deg2Rad);

        float tx = v.x;
        float ty = v.y;
        v.x = (cos * tx) - (sin * ty);
        v.y = (sin * tx) + (cos * ty);
        return v;
    }


    void OnResolutionChanged()
    {
        resetHolderPoints();
        WarmUpTextures();


        resolutionX = thisCamera.pixelWidth;
        resolutionY = thisCamera.pixelHeight;
        gridResolutionX = Mathf.CeilToInt(((float)thisCamera.pixelWidth) / ((float)distanceBeetwenPoints));
        gridResolutionY = Mathf.CeilToInt(((float)thisCamera.pixelHeight) / ((float)distanceBeetwenPoints));
        maxEdge = gridResolutionX + gridResolutionY;
        resolution = (2 * maxEdge) * (2 * maxEdge);
        if (thisCamera.pixelWidth > thisCamera.pixelHeight)
            aspectVector = new Vector2(1.0f, thisCamera.aspect);
        else
            aspectVector = new Vector2(thisCamera.aspect, 1.0f);



        allMagentaPoints = new ComputeBuffer(resolution, sizeof(float) * 2, ComputeBufferType.Append);
        allYellowPoints = new ComputeBuffer(resolution, sizeof(float) * 2, ComputeBufferType.Append);
        allBlackPoints = new ComputeBuffer(resolution, sizeof(float) * 2, ComputeBufferType.Append);
        allCyanPoints = new ComputeBuffer(resolution, sizeof(float) * 2, ComputeBufferType.Append);

        allMagentaPoints.SetCounterValue((uint)resolution);
        allYellowPoints.SetCounterValue((uint)resolution);
        allBlackPoints.SetCounterValue((uint)resolution);
        allCyanPoints.SetCounterValue((uint)resolution);

        float sqrtTwo = Mathf.Sqrt(2.0f);
        float fieldEdge = (gridResolutionX / sqrtTwo + gridResolutionY / sqrtTwo);
        float maxOverlapingFiled = fieldEdge * fieldEdge;
        int maximumVisiblePoints = Mathf.CeilToInt(maxOverlapingFiled);

        visibleCyanPoints = new ComputeBuffer(maximumVisiblePoints, halftonePoint.stride, ComputeBufferType.Append);
        visibleMagentaPoints = new ComputeBuffer(maximumVisiblePoints, halftonePoint.stride, ComputeBufferType.Append);
        visibleYellowPoints = new ComputeBuffer(maximumVisiblePoints, halftonePoint.stride, ComputeBufferType.Append);
        visibleBlackPoints = new ComputeBuffer(maximumVisiblePoints, halftonePoint.stride, ComputeBufferType.Append);

        visibleCyanPoints.SetCounterValue(0);
        visibleMagentaPoints.SetCounterValue(0);
        visibleYellowPoints.SetCounterValue(0);
        visibleBlackPoints.SetCounterValue(0);
        visibleBlackPoints.SetCounterValue(0);

        drawIndirectCyan = new ComputeBuffer(1, sizeof(uint) * 4, ComputeBufferType.IndirectArguments);
        drawIndirectMagenta = new ComputeBuffer(1, sizeof(uint) * 4, ComputeBufferType.IndirectArguments);
        drawIndirectYellow = new ComputeBuffer(1, sizeof(uint) * 4, ComputeBufferType.IndirectArguments);
        drawIndirectBlack = new ComputeBuffer(1, sizeof(uint) * 4, ComputeBufferType.IndirectArguments);

        uint[] startDrawParams = new uint[] { 6, 0, 0, 0 }; // 6 vertex per plane numbers of instances will be copied

        drawIndirectCyan.SetData(startDrawParams);
        drawIndirectMagenta.SetData(startDrawParams);
        drawIndirectYellow.SetData(startDrawParams);
        drawIndirectBlack.SetData(startDrawParams);

        particleScreenSize = new Vector2(((float)distanceBeetwenPoints) / thisCamera.pixelWidth, ((float)distanceBeetwenPoints) / thisCamera.pixelHeight) * particleSizeMultipiler;

        BindBuffers();
    }

    void setupStartupPoints(ref ComputeBuffer buffer, float angle)
    {
        List<Vector2> newVectors = new List<Vector2>();
        float diameter = distanceBeetwenPoints * 2.0f;
        float angleLerp = Mathf.Sin(Mathf.Deg2Rad * angle);
        Vector2 angleNormalizeVector;
        angleNormalizeVector = Vector2.Lerp(Vector2.one, new Vector2(0.55f, 1.77f), Mathf.Abs(angleLerp));

        for (int x = -maxEdge; x < maxEdge; x++)
        {
            for (int y = -maxEdge; y < maxEdge; y++)
            {
                Vector2 gridPoint = new Vector2((diameter * x) / thisCamera.pixelWidth, (diameter * y) / thisCamera.pixelHeight) / aspectVector;
                Vector2 rotatedPoint = (Rotate(gridPoint, angle) * aspectVector - new Vector2(1.0f, 1.0f));
                newVectors.Add(rotatedPoint);
            }
        }
        buffer.SetData(newVectors.ToArray());
        // visibleCyanPoints.SetData(testPoints.ToArray());
        //  Debug.Log(newVectors[newVectors.Count-1].x);
    }

    void BindBuffers()
    {
        kernelCyanVisCalCs = pointsVisibilityCalculator.FindKernel("kernelCyanVisCalCs");
        kernelMagentaVisCalCs = pointsVisibilityCalculator.FindKernel("kernelMagentaVisCalCs");
        kernelYellowVisCalCs = pointsVisibilityCalculator.FindKernel("kernelYellowVisCalCs");
        kernelBlackVisCalCs = pointsVisibilityCalculator.FindKernel("kernelBlackVisCalCs");

        pointsVisibilityCalculator.SetBuffer(kernelCyanVisCalCs, "allCyanPoints", allCyanPoints);
        pointsVisibilityCalculator.SetBuffer(kernelCyanVisCalCs, "visibleCyanPoints", visibleCyanPoints);

        pointsVisibilityCalculator.SetBuffer(kernelMagentaVisCalCs, "allMagentaPoints", allMagentaPoints);
        pointsVisibilityCalculator.SetBuffer(kernelMagentaVisCalCs, "visibleMagentaPoints", visibleMagentaPoints);

        pointsVisibilityCalculator.SetBuffer(kernelYellowVisCalCs, "allYellowPoints", allYellowPoints);
        pointsVisibilityCalculator.SetBuffer(kernelYellowVisCalCs, "visibleYellowPoints", visibleYellowPoints);

        pointsVisibilityCalculator.SetBuffer(kernelBlackVisCalCs, "allBlackPoints", allBlackPoints);
        pointsVisibilityCalculator.SetBuffer(kernelBlackVisCalCs, "visibleBlackPoints", visibleBlackPoints);
        //////////
        pointsAtributesCalculator.SetBuffer(kernelCyanAtributeCalCs, "visibleCyanPoints", visibleCyanPoints);
        pointsAtributesCalculator.SetBuffer(kernelMagentaAtributeCalCs, "visibleMagentaPoints", visibleMagentaPoints);
        pointsAtributesCalculator.SetBuffer(kernelYellowAtributeCalCs, "visibleYellowPoints", visibleYellowPoints);
        pointsAtributesCalculator.SetBuffer(kernelBlackAtributeCalCs, "visibleBlackPoints", visibleBlackPoints);
        /////////

        cyanMat = new Material(particlesShader);
        magentaMat = new Material(particlesShader);
        yellowMat = new Material(particlesShader);
        blackMat = new Material(particlesShader);

        cyanMat.enableInstancing = true;


        cyanMat.SetVector("_Size", particleScreenSize);
        cyanMat.SetTexture("_MainTex", particleTex);

        magentaMat.SetVector("_Size", particleScreenSize);
        magentaMat.SetTexture("_MainTex", particleTex);

        yellowMat.SetVector("_Size", particleScreenSize);
        yellowMat.SetTexture("_MainTex", particleTex);

        blackMat.SetVector("_Size", particleScreenSize);
        blackMat.SetTexture("_MainTex", particleTex);


        cyanMat.SetBuffer("_visiblePoints", visibleCyanPoints);
        cyanMat.SetColor("_Color", Color.cyan);
        magentaMat.SetBuffer("_visiblePoints", visibleMagentaPoints);
        magentaMat.SetColor("_Color", Color.magenta);
        yellowMat.SetBuffer("_visiblePoints", visibleYellowPoints);
        yellowMat.SetColor("_Color", Color.yellow);
        blackMat.SetBuffer("_visiblePoints", visibleBlackPoints);
        blackMat.SetColor("_Color", Color.black);

        setupEffiency();

    }

    void setupEffiency()
    {
        cyanMat.SetFloat("_Efficiency", cyanEfficency);
        magentaMat.SetFloat("_Efficiency", magentaEfficency);
        yellowMat.SetFloat("_Efficiency", yellowEfficency);
        blackMat.SetFloat("_Efficiency", blackEfficency);
    }

    void FindKernels()
    {
        kernelCyanAtributeCalCs = pointsAtributesCalculator.FindKernel("kernelCyanAtributeCalCs");
        kernelMagentaAtributeCalCs = pointsAtributesCalculator.FindKernel("kernelMagentaAtributeCalCs");
        kernelYellowAtributeCalCs = pointsAtributesCalculator.FindKernel("kernelYellowAtributeCalCs");
        kernelBlackAtributeCalCs = pointsAtributesCalculator.FindKernel("kernelBlackAtributeCalCs");
        blurHorID = pointsAtributesCalculator.FindKernel("HorzBlurCs");
        blurVerID = pointsAtributesCalculator.FindKernel("VertBlurCs");
    }

    void Validate()
    {
        if (!pointsVisibilityCalculator)
        {
            Debug.LogError("No compute shaders deteced");
            return;
        }


        if (resolutionX != thisCamera.pixelWidth || resolutionY != thisCamera.pixelHeight || _distanceBeetwenPoints != distanceBeetwenPoints)
            OnResolutionChanged();

        setupStartupPoints(ref allCyanPoints, cyanAngle);
        setupStartupPoints(ref allMagentaPoints, magentaAngle);
        setupStartupPoints(ref allYellowPoints, yellowAngle);
        setupStartupPoints(ref allBlackPoints, blackAngle);

        allCyanPoints.SetCounterValue((uint)resolution);
        allMagentaPoints.SetCounterValue((uint)resolution);
        allYellowPoints.SetCounterValue((uint)resolution);
        allBlackPoints.SetCounterValue((uint)resolution);


        visibleCyanPoints.SetCounterValue(0);
        visibleMagentaPoints.SetCounterValue(0);
        visibleYellowPoints.SetCounterValue(0);
        visibleBlackPoints.SetCounterValue(0);



        pointsVisibilityCalculator.SetInt("numberOfElements", resolution);
        pointsVisibilityCalculator.SetVector("screenParticleSize", particleScreenSize);
        /////
        pointsAtributesCalculator.SetInt("blurRadius", (int)distanceBeetwenPoints);
        pointsAtributesCalculator.SetInt("resolutionX", (int)resolutionX);
        pointsAtributesCalculator.SetInt("resolutionY", (int)resolutionY);
        ////

        int dipstachNumbers = Mathf.CeilToInt(((float)(resolution)) / ((float)(visibilityDipstach)));
        pointsVisibilityCalculator.Dispatch(kernelCyanVisCalCs, dipstachNumbers, 1, 1);
        pointsVisibilityCalculator.Dispatch(kernelMagentaVisCalCs, dipstachNumbers, 1, 1);
        pointsVisibilityCalculator.Dispatch(kernelYellowVisCalCs, dipstachNumbers, 1, 1);
        pointsVisibilityCalculator.Dispatch(kernelBlackVisCalCs, dipstachNumbers, 1, 1);

        // Debug.Log(dipstachNumbers);
        //Debug.Log( testDrawParams[1]); 

        // halftonePoint[] debugValues = new halftonePoint[visibleCyanPoints.count];
        // visibleCyanPoints.GetData(debugValues);

        //Debug.Log( debugValues[0].screenPos); 

        ComputeBuffer.CopyCount(visibleCyanPoints, drawIndirectCyan, sizeof(uint));
        ComputeBuffer.CopyCount(visibleMagentaPoints, drawIndirectMagenta, sizeof(uint));
        ComputeBuffer.CopyCount(visibleYellowPoints, drawIndirectYellow, sizeof(uint));
        ComputeBuffer.CopyCount(visibleBlackPoints, drawIndirectBlack, sizeof(uint));


        uint[] cyanDrawParams = new uint[4];
        drawIndirectCyan.GetData(cyanDrawParams);
        numberOfCyanPoints = (int)cyanDrawParams[1];

        uint[] magentaDrawParams = new uint[4];
        drawIndirectMagenta.GetData(magentaDrawParams);
        numberOfMagentaPoints = (int)magentaDrawParams[1];

        uint[] yellowDrawParams = new uint[4];
        drawIndirectYellow.GetData(yellowDrawParams);
        numberOfYellowPoints = (int)yellowDrawParams[1];
        // Debug.Log(yellowDrawParams[1]);

        uint[] blackDrawParams = new uint[4];
        drawIndirectBlack.GetData(blackDrawParams);
        numberOfBlackPoints = (int)blackDrawParams[1];

        setupEffiency();
    }

    void warmUp()
    {
        if (!SystemInfo.supportsComputeShaders)
        {
            init = false;
            return;
        }
        if (thisCamera == null)
            thisCamera = GetComponent<Camera>();

        resolutionX = thisCamera.pixelWidth;
        resolutionY = thisCamera.pixelHeight;
        _distanceBeetwenPoints = distanceBeetwenPoints;
        FindKernels();
        OnResolutionChanged();
        Validate();
        init = true;
    }

    private void OnEnable()
    {
        warmUp();

    }
    private void OnValidate()
    {
        if (!Application.isPlaying)
            return;
        if (!init)
            warmUp();
        else
            Validate();
    }

    void resetBuffer(ref ComputeBuffer bufferToClear)
    {
        if (bufferToClear != null)
        {
            bufferToClear.Release();
            bufferToClear = null;
        }
    }

    void resetHolderPoints()
    {
        resetBuffer(ref allCyanPoints);
        resetBuffer(ref allMagentaPoints);
        resetBuffer(ref allYellowPoints);
        resetBuffer(ref allBlackPoints);

        resetBuffer(ref visibleCyanPoints);
        resetBuffer(ref visibleMagentaPoints);
        resetBuffer(ref visibleYellowPoints);
        resetBuffer(ref visibleBlackPoints);

        resetBuffer(ref drawIndirectCyan);
        resetBuffer(ref drawIndirectMagenta);
        resetBuffer(ref drawIndirectYellow);
        resetBuffer(ref drawIndirectBlack);

    }


    protected void WarmUpTextures()
    {
        CreateTextue(ref verBlurOutput);
        CreateTextue(ref horBlurOutput);
        CreateTextue(ref tempSource);


        pointsAtributesCalculator.SetTexture(blurHorID, "source", tempSource);
        pointsAtributesCalculator.SetTexture(blurHorID, "horBlurOutput", horBlurOutput);

        pointsAtributesCalculator.SetTexture(blurVerID, "horBlurOutput", horBlurOutput);
        pointsAtributesCalculator.SetTexture(blurVerID, "verBlurOutput", verBlurOutput);

        pointsAtributesCalculator.SetTexture(kernelCyanAtributeCalCs, "verBlurOutput", verBlurOutput);
        pointsAtributesCalculator.SetTexture(kernelMagentaAtributeCalCs, "verBlurOutput", verBlurOutput);
        pointsAtributesCalculator.SetTexture(kernelYellowAtributeCalCs, "verBlurOutput", verBlurOutput);
        pointsAtributesCalculator.SetTexture(kernelBlackAtributeCalCs, "verBlurOutput", verBlurOutput);
    }

    public void CreateTextue(ref RenderTexture textureToMake)
    {
        textureToMake = new RenderTexture(resolutionX, resolutionY, 0, RenderTextureFormat.Default, RenderTextureReadWrite.Default);
        textureToMake.enableRandomWrite = true;
        textureToMake.wrapMode = TextureWrapMode.Clamp;
        textureToMake.Create();
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {


        if (!init)
        {
            Graphics.Blit(source, destination);
            warmUp();
            return;
        }


        int horizontalBlurDisX = Mathf.CeilToInt(((float)resolutionX / 256.0f)); // it is here becouse res of window can change
        int horizontalBlurDisY = Mathf.CeilToInt(((float)resolutionY / 256.0f));

        Graphics.Blit(source, tempSource);
        pointsAtributesCalculator.Dispatch(blurHorID, horizontalBlurDisX, resolutionY, 1);
        pointsAtributesCalculator.Dispatch(blurVerID, resolutionX, horizontalBlurDisY, 1);

        pointsAtributesCalculator.Dispatch(kernelCyanAtributeCalCs, Mathf.CeilToInt(numberOfCyanPoints / 256.0f), 1, 1);
        pointsAtributesCalculator.Dispatch(kernelMagentaAtributeCalCs, Mathf.CeilToInt(numberOfMagentaPoints / 256.0f), 1, 1);
        pointsAtributesCalculator.Dispatch(kernelYellowAtributeCalCs, Mathf.CeilToInt(numberOfYellowPoints / 256.0f), 1, 1);
        pointsAtributesCalculator.Dispatch(kernelBlackAtributeCalCs, Mathf.CeilToInt(numberOfBlackPoints / 256.0f), 1, 1);

        GL.Clear(true, true, Color.white);



        cyanMat.SetPass(0);
        Graphics.DrawProcedural(MeshTopology.Triangles, numberOfCyanPoints *6, 1);

        magentaMat.SetPass(0);
        Graphics.DrawProcedural(MeshTopology.Triangles, numberOfMagentaPoints * 6, 1);

        yellowMat.SetPass(0);
        Graphics.DrawProcedural(MeshTopology.Triangles, numberOfYellowPoints * 6, 1);

        blackMat.SetPass(0);
        Graphics.DrawProcedural(MeshTopology.Triangles, numberOfBlackPoints * 6, 1);

    }

    private void FreeMemory()
    {
        resetHolderPoints();
        init = false;
    }

    private void OnDisable()
    {
        FreeMemory();
    }
    private void OnDestroy()
    {
        FreeMemory();
    }


}