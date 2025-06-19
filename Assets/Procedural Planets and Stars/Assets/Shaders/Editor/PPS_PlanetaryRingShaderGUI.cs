using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class PPS_PlanetaryRingShaderGUI : PPS_AProjectionShaderGUI
{
    public override void OnGUI(MaterialEditor _editor, MaterialProperty[] _properties)
    {
        Material targetMat = _editor.target as Material;

        DoSettingsArea(targetMat, _editor, _properties);
        DoMainArea(_editor, _properties);
    }

    private void DoSettingsArea(Material _targetMat, MaterialEditor _editor, MaterialProperty[] _properties)
    {
        GUILayout.Label("Settings", EditorStyles.boldLabel);

        CameraProjection projection = CurrentProjection(_targetMat);
        EditorGUI.BeginChangeCheck();
        projection = (CameraProjection)EditorGUILayout.EnumPopup("Projection", projection);
        if (EditorGUI.EndChangeCheck())
        {
            _editor.RegisterPropertyChangeUndo("Projection");
            SetKeyword(_targetMat, "_CAMERA_PERSPECTIVE", projection == CameraProjection.Perspective);
            SetKeyword(_targetMat, "_CAMERA_ORTHOGRAPHIC", projection == CameraProjection.Orthographic);
        }

        bool toggle;
        DoAnimationPart(_targetMat, _editor, _properties, out toggle);

        ShowToggle(_targetMat, _editor, out toggle, "Simple Rendering", "_SIMPLE_ON", "1D rendering");
    }

    private void DoMainArea(MaterialEditor _editor, MaterialProperty[] _properties)
    {
        GUILayout.Label("Main", EditorStyles.boldLabel);
        
        ShowTextureSingleLine(_editor, _properties, "Gradient", "_Gradient", "");
        ShowTextureSingleLine(_editor, _properties, "Main Texture", "_MainTex", "");
        
        ShowShaderProperty(_editor, _properties, "Radius", "_Radius", "");
        ShowShaderProperty(_editor, _properties, "Noise", "_Noise", "");
        ShowShaderProperty(_editor, _properties, "Shadow", "_Shadow", "");
    }
}
