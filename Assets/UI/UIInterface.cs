#if UNITY_EDITOR
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using TMPro;
using System.Linq;
using UnityEditor.SceneManagement;

[CustomEditor(typeof(UIInterface))]
public class UIInterfaceEditor : Editor
{
    UIInterface linkedDisplayOrganizer => (UIInterface)target;

    public override void OnInspectorGUI()
    {
        DrawDefaultInspector();

        if (GUILayout.Button("Clean up"))
        {
            linkedDisplayOrganizer.CleanUp();
        }

        if (GUILayout.Button("Clean up all rect transforms"))
        {
            PrefabStage currentStage = PrefabStageUtility.GetCurrentPrefabStage();

            RectTransform[] allRects;

            if (currentStage == null)
            {
                allRects = Object.FindObjectsByType<RectTransform>(FindObjectsSortMode.None);
            }
            else
            {
                GameObject prefabRoot = currentStage.prefabContentsRoot;
                allRects = prefabRoot.GetComponentsInChildren<RectTransform>(true);
            }

            Debug.Log($"All: {allRects.Length}");

            int reset = 0;

            foreach (RectTransform rect in allRects)
            {
                if (rect.gameObject == ((MonoBehaviour)target).gameObject)
                    continue;

                UnityEditor.PropertyModification[] modifications = PrefabUtility.GetPropertyModifications(rect);
                
                // If the modifications array is not null and has items, it has overrides
                if (modifications != null && modifications.Length > 0)
                {
                    PrefabUtility.RevertObjectOverride(rect, InteractionMode.AutomatedAction);
                    EditorUtility.SetDirty(rect);
                    reset++;
                    if(reset == 100)
                        break;
                }
                
            }

            Debug.Log($"Reset: {reset}");
        }
    }
}

public class UIInterface : MonoBehaviour
{
    [SerializeField] TMP_Text tile;
    [SerializeField] TMP_Text description;

    public string Title
    {
        get
        {
            return tile.text;
        }
        set
        {
            tile.text = value;
        }
    }

    public string Description
    {
        get
        {
            return description.text;
        }
        set
        {
            description.text = value;
        }
    }

    public void CleanUp()
    {
        // No spaces in title
        string originalString = tile.text;
        string cleanString = originalString.Replace("\r", "").Replace("\n", "");
        tile.text = cleanString;

        // Clean up rect transform
        RectTransform[] rectTransforms = transform.GetComponentsInChildren<RectTransform>(true);
        foreach (RectTransform rect in rectTransforms)
        {
            PrefabUtility.RevertObjectOverride(rect, InteractionMode.AutomatedAction);
        }
    }

    
}
#endif