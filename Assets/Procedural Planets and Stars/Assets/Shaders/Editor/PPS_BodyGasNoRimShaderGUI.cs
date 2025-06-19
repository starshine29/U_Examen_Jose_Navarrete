using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class PPS_BodyGasNoRimShaderGUI : PPS_ABodyWLightingShaderGUI
{
    protected override void DoMainArea(MaterialEditor _editor, MaterialProperty[] _properties)
    {
        base.DoMainArea(_editor, _properties);
        ShowShaderProperty(_editor, _properties, "Distortion", "_Distortion", "");
    }

    protected override void DoSettingsArea(Material _targetMat, MaterialEditor _editor, MaterialProperty[] _properties)
    {
        base.DoSettingsArea(_targetMat, _editor, _properties);

        bool toggle;
        ShowToggle(_targetMat, _editor, out toggle, "Quality Lighting", "_QUALITYLIGHTING_ON", "");
        ShowShaderProperty(_editor, _properties, "Ambient Light", "_AmbientLight", "");
        DoAnimationPart(_targetMat, _editor, _properties, out toggle);
    }
}
