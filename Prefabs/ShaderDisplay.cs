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
    [SerializeField] TMP_Text titleElement;
    [SerializeField] UIInterface linkedInterface;
    [SerializeField] MeshRenderer linkedMeshRenderer;
    [SerializeField] Transform sliderHolder;
    [SerializeField] Transform background;

    [Header("Values")]
    [SerializeField] string title;
    [SerializeField] [TextArea(3, 10)] string description;
    [SerializeField] Material linkedMaterial;
    
    static void RegisterChange(Object linkedObject, string linkedMessage)
    {
        Undo.RegisterCompleteObjectUndo(linkedObject, linkedMessage);
        EditorUtility.SetDirty(linkedObject);
    }

    public void UpdateSize()
    {
        bool hasSliders = sliderHolder.childCount > 0;
        sliderHolder.gameObject.SetActive(hasSliders);
        RegisterChange(gameObject, "Updated size");

        float width = hasSliders ? 1f : 1.0f;
        if (background)
        {
            background.localScale = new Vector3(width, background.localScale.y, background.localScale.z);
            RegisterChange(background, "Updated size");
        }
    }
    
    public void GetData()
    {
        if (title.Equals("Title")||title.Length == 0)
            title = titleElement.text;
        title = title.Replace("\r", "").Replace("\n", " ");
        description = linkedInterface.Description;
        if(linkedMeshRenderer)
            linkedMaterial = linkedMeshRenderer.sharedMaterial;
        RegisterChange(this, "Got data");
    }

    public void SetData()
    {
        
        titleElement.text = title;
        linkedInterface.Description = description;
        RegisterChange(titleElement, "Set data");

        if (linkedMeshRenderer)
        {
            linkedMeshRenderer.sharedMaterial = linkedMaterial;
            RegisterChange(linkedMeshRenderer, "Set data");
            
            foreach(Transform child in sliderHolder)
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
    }

}
#endif