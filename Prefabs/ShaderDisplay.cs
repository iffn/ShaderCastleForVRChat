#if UNITY_EDITOR
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using TMPro;
using VRC.SDK3.Editor;
using UnityEditor.SceneManagement;
using UnityEngine.Tilemaps;

[CustomEditor(typeof(ShaderDisplay))]
public class ShaderDisplayEditor : Editor
{
    ShaderDisplay linkedDisplay => (ShaderDisplay)target;

    public override void OnInspectorGUI()
    {
        DrawDefaultInspector();

        if (GUILayout.Button("Get"))
        {
            linkedDisplay.GetData();
        }

        if (GUILayout.Button("Set"))
        {
            linkedDisplay.SetData();
        }

        if (GUILayout.Button("Set all"))
        {
            PrefabStage currentStage = PrefabStageUtility.GetCurrentPrefabStage();

            ShaderDisplay[] allShaderDisplays;

            if (currentStage == null)
            {
                allShaderDisplays = Object.FindObjectsByType<ShaderDisplay>(FindObjectsSortMode.None);
            }
            else
            {
                GameObject prefabRoot = currentStage.prefabContentsRoot;
                allShaderDisplays = prefabRoot.GetComponentsInChildren<ShaderDisplay>(true);
            }

            foreach (ShaderDisplay display in allShaderDisplays)
            {
                display.SetData();
                display.UpdateSize();
            }
        }

        if (GUILayout.Button("Get all"))
        {
            PrefabStage currentStage = PrefabStageUtility.GetCurrentPrefabStage();

            ShaderDisplay[] allShaderDisplays;

            if (currentStage == null)
            {
                allShaderDisplays = Object.FindObjectsByType<ShaderDisplay>(FindObjectsSortMode.None);
            }
            else
            {
                GameObject prefabRoot = currentStage.prefabContentsRoot;
                allShaderDisplays = prefabRoot.GetComponentsInChildren<ShaderDisplay>(true);
            }

            foreach (ShaderDisplay display in allShaderDisplays)
            {
                display.GetData();
            }
        }
    }
}

public class ShaderDisplay : MonoBehaviour
{
    [Header("References")]
    [SerializeField] UIInterface mainInterface;
    [SerializeField] UIInterface secondInterface;
    [SerializeField] MeshRenderer linkedMeshRenderer;
    [SerializeField] Transform background;

    [Header("Values")]
    [SerializeField] string title;
    [SerializeField] [TextArea(3, 10)] string description;
    [SerializeField] Material linkedMaterial;
    [SerializeField] bool separateDescriptionCanvas = false;
    
    UIInterface CurrentUIInterface
    {
        get
        {
            if(secondInterface == null)
                return mainInterface;
            return separateDescriptionCanvas ? secondInterface : mainInterface;
        }
    }

    UIInterface OtherUIInterface
    {
        get
        {
            if(secondInterface == null)
                return null;
            return separateDescriptionCanvas ? mainInterface : secondInterface;
        }
    }

    static void RegisterChange(Object linkedObject, string linkedMessage)
    {
        Undo.RegisterCompleteObjectUndo(linkedObject, linkedMessage);
        EditorUtility.SetDirty(linkedObject);
    }

    public void UpdateSize()
    {
        /*
        bool hasSliders = secondSliderHolder.childCount > 0;
        secondSliderHolder.gameObject.SetActive(hasSliders);
        RegisterChange(gameObject, "Updated size");

        float width = hasSliders ? 1f : 1.0f;
        if (background)
        {
            background.localScale = new Vector3(width, background.localScale.y, background.localScale.z);
            RegisterChange(background, "Updated size");
        }
        */
    }
    
    public void GetData()
    {
        if (title.Equals("Title")||title.Length == 0)
            title = CurrentUIInterface.Title;
        title = title.Replace("\r", "").Replace("\n", " ");
        description = CurrentUIInterface.Description;
        if(linkedMeshRenderer)
            linkedMaterial = linkedMeshRenderer.sharedMaterial;
        RegisterChange(this, "Got data");
        EditorUtility.SetDirty(this);
        EditorSceneManager.MarkSceneDirty(gameObject.scene);
    }

    public void SetData()
    {
        CurrentUIInterface.Title = title;
        CurrentUIInterface.Description = description;
        
        if(OtherUIInterface)
            OtherUIInterface.Title = title;

        CurrentUIInterface.gameObject.SetActive(true);
        CurrentUIInterface.SliderHolder.gameObject.SetActive(CurrentUIInterface.SliderHolder.childCount > 0);

        if(secondInterface)
        {
            secondInterface.gameObject.SetActive(separateDescriptionCanvas);
            OtherUIInterface.SliderHolder.gameObject.SetActive(false);

            if (separateDescriptionCanvas)
            {
                OtherUIInterface.Description = "";
            }
        }

        if (linkedMeshRenderer)
        {
            linkedMeshRenderer.sharedMaterial = linkedMaterial;
            RegisterChange(linkedMeshRenderer, "Set data");

            if (OtherUIInterface)
            {
                MoveChildren(OtherUIInterface.SliderHolder, CurrentUIInterface.SliderHolder);
            }

            foreach(Transform child in CurrentUIInterface.SliderHolder)
            {
                if (child.TryGetComponent<MaterialRGBSlider>(out MaterialRGBSlider rgbSlider))
                {
                    rgbSlider.linkedMaterial = linkedMaterial;
                    RegisterChange(rgbSlider, "Set data");
                }
                else if (child.TryGetComponent<MaterialFloatSlider>(out MaterialFloatSlider floatSlider))
                {
                    floatSlider.linkedMaterial = linkedMaterial;
                    RegisterChange(floatSlider, "Set data");
                }
            }
        }

        EditorSceneManager.MarkSceneDirty(gameObject.scene);
    }

    public void MoveChildren(Transform source, Transform target)
    {
        if (source == null || target == null) return;

        Undo.RegisterCompleteObjectUndo(target, "Move Children");

        while (source.childCount > 0)
        {
            Transform child = source.GetChild(0);
            
            child.SetParent(target);
            child.localPosition = Vector3.zero;
            child.localScale = Vector3.one;
        }

        EditorUtility.SetDirty(source);
        EditorUtility.SetDirty(target);
    }
}
#endif