using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PPS_AProjectionShaderGUI : PPS_AShaderGUI
{
    protected enum CameraProjection { Perspective, Orthographic }

    protected CameraProjection CurrentProjection(Material _targetMat)
    {
        CameraProjection projection = CameraProjection.Perspective;
        if (_targetMat.IsKeywordEnabled("_CAMERA_ORTHOGRAPHIC"))
            projection = CameraProjection.Orthographic;

        return projection;
    }
}
