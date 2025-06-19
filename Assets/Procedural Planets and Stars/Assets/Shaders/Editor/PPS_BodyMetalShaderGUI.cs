using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class PPS_BodyMetalShaderGUI : PPS_ABodyWLightingShaderGUI
{
    public override void OnGUI(MaterialEditor _editor, MaterialProperty[] _properties)
    {
        base.OnGUI(_editor, _properties);
        DoLightsArea(_editor, _properties);
    }

    protected override void DoSettingsArea(Material _targetMat, MaterialEditor _editor, MaterialProperty[] _properties)
    {
        base.DoSettingsArea(_targetMat, _editor, _properties);
        ShowShaderProperty(_editor, _properties, "Ambient Light", "_AmbientLight", "");
    }

    protected override void DoMainArea(MaterialEditor _editor, MaterialProperty[] _properties)
    {
        base.DoMainArea(_editor, _properties);
        ShowTextureSingleLine(_editor, _properties, "Detail Texture", "_DetailTex", "");
        ShowShaderProperty(_editor, _properties, "Bump Scale", "_BumpScale", "");
        ShowShaderProperty(_editor, _properties, "Specular Color", "_SpecularColor", "");
        ShowShaderProperty(_editor, _properties, "Specular Highlight", "_SpecularHighlight", "");
    }

    private void DoLightsArea(MaterialEditor _editor, MaterialProperty[] _properties)
    {
        GUILayout.Label("Lights", EditorStyles.boldLabel);

        ShowTextureSingleLine(_editor, _properties, "Texture", "_LightsTex", "_LightsColor", "");
        ShowShaderProperty(_editor, _properties, "Height Mask", "_LightsHeightMask", "");
    }
}
