#if UNITY_EDITOR
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using TMPro;
using System.Linq;
using UnityEditor.SceneManagement;
using UnityEngine.UI;

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

            System.Collections.Generic.IEnumerable<System.Linq.IGrouping<GameObject, RectTransform>> rectsByPrefab = allRects
                .Where(r => r.gameObject != ((MonoBehaviour)target).gameObject && PrefabUtility.IsPartOfPrefabInstance(r))
                .GroupBy(r => PrefabUtility.GetNearestPrefabInstanceRoot(r.gameObject));

            foreach (System.Linq.IGrouping<GameObject, RectTransform> prefabGroup in rectsByPrefab)
            {
                if (reset >= 100) break;

                // Bulk fetch every single override on this prefab instance in one single call
                System.Collections.Generic.List<ObjectOverride> allPrefabOverrides = PrefabUtility.GetObjectOverrides(prefabGroup.Key);
                
                // Hash the overridden components for instant lookups
                System.Collections.Generic.HashSet<Object> overriddenObjects = new System.Collections.Generic.HashSet<Object>(allPrefabOverrides.Select(x => x.instanceObject));

                foreach (RectTransform rect in prefabGroup)
                {
                    if (overriddenObjects.Contains(rect))
                    {
                        Undo.RegisterCompleteObjectUndo(rect, "Clean RectTransform");
                        PrefabUtility.RevertObjectOverride(rect, InteractionMode.AutomatedAction);
                        EditorUtility.SetDirty(rect);
                        
                        reset++;
                        if (reset >= 500)
                            Debug.Log("Early stop, run again for more");
                            break;
                    }
                }
            }

            if (reset > 0)
            {
                if (currentStage != null)
                    EditorSceneManager.MarkSceneDirty(currentStage.scene);
                else
                    EditorSceneManager.MarkSceneDirty(UnityEngine.SceneManagement.SceneManager.GetActiveScene());
            }

            Debug.Log($"Reset: {reset}");
        }
    }
}

public class UIInterface : MonoBehaviour
{
    [SerializeField] TMP_Text title;
    [SerializeField] TMP_Text description;
    [SerializeField] LayoutElement descriptionScaler;
    [SerializeField] Transform sliderHolder;

    public string Title
    {
        get
        {
            return title.text;
        }
        set
        {
            title.text = value;
            Undo.RegisterCompleteObjectUndo(this, "Got data");
            EditorUtility.SetDirty(title);
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
            Undo.RegisterCompleteObjectUndo(this, "Got data");
            EditorUtility.SetDirty(description);
            descriptionScaler.minHeight = description.rectTransform.sizeDelta.y;
            EditorUtility.SetDirty(descriptionScaler);
        }
    }

    public Transform SliderHolder
    {
        get
        {
            return sliderHolder;
        }
    }

    public void CleanUp()
    {
        // No spaces in title
        string originalString = title.text;
        string cleanString = originalString.Replace("\r", "").Replace("\n", "");
        title.text = cleanString;

        // Clean up rect transform
        RectTransform[] rectTransforms = transform.GetComponentsInChildren<RectTransform>(true);
        foreach (RectTransform rect in rectTransforms)
        {
            PrefabUtility.RevertObjectOverride(rect, InteractionMode.AutomatedAction);
        }
    }

    
}
#endif