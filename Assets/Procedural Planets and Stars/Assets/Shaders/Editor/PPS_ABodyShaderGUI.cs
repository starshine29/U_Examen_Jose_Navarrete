using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class PPS_ABodyShaderGUI : PPS_AProjectionShaderGUI
{
    protected enum ShaderQuality { Low, Medium, High, Very_High }
    protected ShaderQuality CurrentShaderQuality(Material _targetMat)
    {
        ShaderQuality projection = ShaderQuality.High;
        if (_targetMat.IsKeywordEnabled("_QUALITY_VERYHIGH"))
            projection = ShaderQuality.Very_High;
        else if (_targetMat.IsKeywordEnabled("_QUALITY_MEDIUM"))
            projection = ShaderQuality.Medium;
        else if (_targetMat.IsKeywordEnabled("_QUALITY_LOW"))
            projection = ShaderQuality.Low;

        return projection;
    }

    public override void OnGUI(MaterialEditor _editor, MaterialProperty[] _properties)
    {
        Material targetMat = _editor.target as Material;
        DoSettingsArea(targetMat, _editor, _properties);
        DoMainArea(_editor, _properties);
    }

    protected virtual void DoSettingsArea(Material _targetMat, MaterialEditor _editor, MaterialProperty[] _properties)
    {
        GUILayout.Label("Settings", EditorStyles.boldLabel);

        CameraProjection projection = CurrentProjection(_targetMat);
        EditorGUI.BeginChangeCheck();
        projection = (CameraProjection)EditorGUILayout.EnumPopup(new GUIContent("Projection", "_Camera"), projection);
        if (EditorGUI.EndChangeCheck())
        {
            _editor.RegisterPropertyChangeUndo("Projection");
            SetKeyword(_targetMat, "_CAMERA_PERSPECTIVE", projection == CameraProjection.Perspective);
            SetKeyword(_targetMat, "_CAMERA_ORTHOGRAPHIC", projection == CameraProjection.Orthographic);
        }

        ShaderQuality shaderQuality = CurrentShaderQuality(_targetMat);
        EditorGUI.BeginChangeCheck();
        shaderQuality = (ShaderQuality)EditorGUILayout.EnumPopup(new GUIContent("Quality", "_Quality"), shaderQuality);
        if (EditorGUI.EndChangeCheck())
        {
            _editor.RegisterPropertyChangeUndo("Quality");
            SetKeyword(_targetMat, "_QUALITY_VERYHIGH", shaderQuality == ShaderQuality.Very_High);
            SetKeyword(_targetMat, "_QUALITY_HIGH", shaderQuality == ShaderQuality.High);
            SetKeyword(_targetMat, "_QUALITY_MEDIUM", shaderQuality == ShaderQuality.Medium);
            SetKeyword(_targetMat, "_QUALITY_LOW", shaderQuality == ShaderQuality.Low);
        }
    }

    protected virtual void DoMainArea(MaterialEditor _editor, MaterialProperty[] _properties)
    {
        GUILayout.Label("Main", EditorStyles.boldLabel);

        ShowTextureSingleLine(_editor, _properties, "Gradient", "_Gradient", "");
        ShowTextureSingleLine(_editor, _properties, "Main Texture", "_MainTex", "");
    }
}
