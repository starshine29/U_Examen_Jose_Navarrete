using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class PPS_BodySunShaderGUI : PPS_ABodyShaderGUI
{
    public override void OnGUI(MaterialEditor _editor, MaterialProperty[] _properties)
    {
        base.OnGUI(_editor, _properties);
        DoRimArea(_editor, _properties);
    }

    protected override void DoSettingsArea(Material _targetMat, MaterialEditor _editor, MaterialProperty[] _properties)
    {
        base.DoSettingsArea(_targetMat, _editor, _properties);

        bool toggle;
        ShowToggle(_targetMat, _editor, out toggle, "Quality Lighting", "_QUALITYLIGHTING_ON", "");
        DoAnimationPart(_targetMat, _editor, _properties, out toggle);
        ShowToggle(_targetMat, _editor, out toggle, "Fix Poles", "_FIXPOLES_ON", "");
    }

    protected override void DoMainArea(MaterialEditor _editor, MaterialProperty[] _properties)
    {
        base.DoMainArea(_editor, _properties);
        ShowShaderProperty(_editor, _properties, "Iris", "_Iris", "");
    }

    private void DoRimArea(MaterialEditor _editor, MaterialProperty[] _properties)
    {
        GUILayout.Label("Rim", EditorStyles.boldLabel);

        ShowShaderProperty(_editor, _properties, "Color", "_RimColor", "");
        ShowShaderProperty(_editor, _properties, "Radius", "_RimRadius", "");
    }
}
