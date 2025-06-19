using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class PPS_BodySolidNoRimShaderGUI : PPS_ABodyWLightingShaderGUI
{
    public override void OnGUI(MaterialEditor _editor, MaterialProperty[] _properties)
    {
        base.OnGUI(_editor, _properties);
        DoLiquidArea(_editor, _properties);
        DoLightsArea(_editor, _properties);
        DoCloudsArea(_editor, _properties);
    }

    protected override void DoSettingsArea(Material _targetMat, MaterialEditor _editor, MaterialProperty[] _properties)
    {
        base.DoSettingsArea(_targetMat, _editor, _properties);

        bool toggle;
        ShowToggle(_targetMat, _editor, out toggle, "Quality Lighting", "_QUALITYLIGHTING_ON", "");
        ShowShaderProperty(_editor, _properties, "Ambient Light", "_AmbientLight", "");
        ShowToggle(_targetMat, _editor, out toggle, "Fix Poles", "_FIXPOLES_ON", "");
        ShowShaderProperty(_editor, _properties, "Texture LOD", "_TexLOD", "");
        ShowToggle(_editor.target as Material, _editor, out toggle, "Clouds", "_CLOUDS_ON", "");
        if (toggle)
        {
            EditorGUI.indentLevel++;
            DoAnimationPart(_targetMat, _editor, _properties, out toggle);
            EditorGUI.indentLevel--;
        }
    }

    protected override void DoMainArea(MaterialEditor _editor, MaterialProperty[] _properties)
    {
        base.DoMainArea(_editor, _properties);
        ShowTextureSingleLine(_editor, _properties, "Plain Texture", "_PlainTex", "");
        ShowTextureSingleLine(_editor, _properties, "Masks Texture", "_MasksTex", "");
        ShowShaderProperty(_editor, _properties, "Bump Scale", "_BumpScale", "");

        GUILayout.Label("Terrain", EditorStyles.boldLabel);
        ShowShaderProperty(_editor, _properties, "Terrain Height", "_TerrainHeight", "");
        ShowShaderProperty(_editor, _properties, "Terraform Mask", "_TerraformMask", "");
        ShowShaderProperty(_editor, _properties, "Terraform Function", "_TerraformFunction", "");

        GUILayout.Label("Ice", EditorStyles.boldLabel);
        ShowTextureSingleLine(_editor, _properties, "Gradient", "_IceGradient", "");
        ShowShaderProperty(_editor, _properties, "Polar Ice", "_PolarIce", "");
        ShowShaderProperty(_editor, _properties, "Mountain Ice", "_MountainIce", "");
    }

    private void DoLiquidArea(MaterialEditor _editor, MaterialProperty[] _properties)
    {
        GUILayout.Label("Liquid", EditorStyles.boldLabel);
        ShowTextureSingleLine(_editor, _properties, "Gradient", "_LiquidGradient", "");
        ShowShaderProperty(_editor, _properties, "Height", "_LiquidHeight", "");
        ShowShaderProperty(_editor, _properties, "Coast Reach", "_LiquidCoastReach", "");
        ShowShaderProperty(_editor, _properties, "Emission Color", "_LiquidEmissionColor", "");
        ShowShaderProperty(_editor, _properties, "Emission", "_LiquidEmission", "");
        ShowShaderProperty(_editor, _properties, "Specular Color", "_SpecularColor", "");
        ShowShaderProperty(_editor, _properties, "Specular Highlight", "_SpecularHighlight", "");
    }

    private void DoLightsArea(MaterialEditor _editor, MaterialProperty[] _properties)
    {
        GUILayout.Label("Lights", EditorStyles.boldLabel);
        ShowTextureSingleLine(_editor, _properties, "Texture", "_LightsTex", "_LightsColor", "");
        ShowShaderProperty(_editor, _properties, "Height Mask", "_LightsHeightMask", "");
    }

    private void DoCloudsArea(MaterialEditor _editor, MaterialProperty[] _properties)
    {
        bool toggle = Array.IndexOf((_editor.target as Material).shaderKeywords, "_CLOUDS_ON") != -1;

        if (toggle)
        {
            GUILayout.Label("Clouds", EditorStyles.boldLabel);
            ShowTextureSingleLine(_editor, _properties, "Texture", "_CloudsTex", "_CloudsColor1", "_CloudsUVTile", "");
            ShowTextureSingleLine(_editor, _properties, "Polar Texture", "_CloudsPolarTex", "_CloudsColor2", "");
            ShowShaderProperty(_editor, _properties, "Volume", "_CloudsVolume", "");
            ShowShaderProperty(_editor, _properties, "Opacity", "_CloudsOpacity", "");
        }
    }
}
