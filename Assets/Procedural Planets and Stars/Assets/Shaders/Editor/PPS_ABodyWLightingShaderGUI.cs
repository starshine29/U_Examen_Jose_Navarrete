using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class PPS_ABodyWLightingShaderGUI : PPS_ABodyShaderGUI
{
    protected enum LightingType { Unity, Central, Custom }
    protected LightingType CurrentLightingType(Material _targetMat)
    {
        LightingType projection = LightingType.Custom;
        if (_targetMat.IsKeywordEnabled("_LIGHTING_UNITY"))
            projection = LightingType.Unity;
        else if (_targetMat.IsKeywordEnabled("_LIGHTING_CENTRAL"))
            projection = LightingType.Central;

        return projection;
    }

    protected override void DoSettingsArea(Material _targetMat, MaterialEditor _editor, MaterialProperty[] _properties)
    {
        base.DoSettingsArea(_targetMat, _editor, _properties);

        LightingType lightingType = CurrentLightingType(_targetMat);
        EditorGUI.BeginChangeCheck();
        lightingType = (LightingType)EditorGUILayout.EnumPopup(new GUIContent("Lighting", "_Lighting"), lightingType);
        if (EditorGUI.EndChangeCheck())
        {
            _editor.RegisterPropertyChangeUndo("Lighting");
            SetKeyword(_targetMat, "_LIGHTING_UNITY", lightingType == LightingType.Unity);
            SetKeyword(_targetMat, "_LIGHTING_CENTRAL", lightingType == LightingType.Central);
            SetKeyword(_targetMat, "_LIGHTING_CUSTOM", lightingType == LightingType.Custom);
        }

        if (lightingType == LightingType.Custom)
        {
            EditorGUI.indentLevel++;
            ShowShaderProperty(_editor, _properties, "Light Direction", "_LightDirection", "");
            EditorGUI.indentLevel--;
        }

    }
}
