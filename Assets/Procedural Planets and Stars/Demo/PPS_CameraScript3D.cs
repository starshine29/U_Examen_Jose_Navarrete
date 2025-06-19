using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PPS_CameraScript3D : MonoBehaviour
{
    public float rotationSpeed = 20;

    void Update()
    {
        transform.Rotate(new Vector2(Input.GetAxis("Vertical"), -Input.GetAxis("Horizontal")) * rotationSpeed * Time.deltaTime);
    }
}
