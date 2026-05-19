#if UNITY_EDITOR

using System;
using System.Collections;
using System.Collections.Generic;
using Unity.Mathematics;
using UnityEditor;
using UnityEngine;

[CustomEditor(typeof(ArcArrangement))]

public class ArcArrangementEditor : Editor
{
    ArcArrangement linkedArcArrangement => (ArcArrangement)target;

    public override void OnInspectorGUI()
    {
        DrawDefaultInspector();

        if (GUILayout.Button("Arrange elements"))
        {
            linkedArcArrangement.Arrange();
        }
    }
}

public class ArcArrangement : MonoBehaviour
{
    public float offset;
    public float angleOffsetDeg;

    public bool arrnageClockwise = true;
    public bool inverseOrder = false;

    public bool halfOffset = false;

    public bool arrangeAroundTheCenter = false;

    public float angleOffsetRad => angleOffsetDeg * Mathf.Deg2Rad;

    public void Arrange()
    {
        List<Transform> children = new List<Transform>();

        foreach(Transform child in transform)
        {
            if(child.gameObject.activeSelf)
                children.Add(child);
        }
        
        int childCount = children.Count;
        
        for (int i = 0; i < childCount; i++)
        {
            float angleRad;
            Transform child;

            float inverseArrangement = arrnageClockwise ? 1.0f : -1.0f;

            if (arrangeAroundTheCenter)
            {
                inverseArrangement *= -1.0f;

                child = children[i];

                float totalAngleRad = inverseArrangement * (childCount - 1) * angleOffsetRad;

                angleRad = -totalAngleRad * 0.5f + inverseArrangement * i * angleOffsetRad;
            }
            else
            {
                int index = inverseOrder ? childCount - 1 - i : i;

                child = children[index];

                float usedHalfOffset = halfOffset ? 0.5f : 0.0f;

                angleRad = -inverseArrangement * (i + usedHalfOffset) * angleOffsetRad;
            }

            child.localRotation = Quaternion.Euler(0, -angleRad * Mathf.Rad2Deg, 0);

            child.localPosition = new Vector3(
                - Mathf.Sin(angleRad) * offset,
                0,
                Mathf.Cos(angleRad) * offset
            );
        }
    }
}

#endif