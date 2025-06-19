using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class PPS_BodyGasShaderGUI : PPS_BodyGasNoRimShaderGUI
{
    public override void OnGUI(MaterialEditor _editor, MaterialProperty[] _properties)
    {
        base.OnGUI(_editor, _properties);
        DoRimArea(_editor, _properties);
    }

    private void DoRimArea(MaterialEditor _editor, MaterialProperty[] _properties)
    {
        GUILayout.Label("Rim", EditorStyles.boldLabel);

        ShowShaderProperty(_editor, _properties, "Color", "_RimColor", "");
        ShowShaderProperty(_editor, _properties, "Radius", "_RimRadius", "");
        ShowShaderProperty(_editor, _properties, "Power", "_RimPower", "");
        ShowShaderProperty(_editor, _properties, "Opacity", "_RimOpacity", "");
    }
}
