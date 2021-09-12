using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteAlways]
public class LookAtCamera : MonoBehaviour
{
    // Start is called before the first frame update

    // Update is called once per frame
    void Update()
    {
        if(Camera.current != null)
            this.transform.LookAt(Camera.current.transform);
    }
}
