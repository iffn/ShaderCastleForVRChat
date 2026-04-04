
using TMPro;
using UdonSharp;
using UnityEngine;
using UnityEngine.UI;
using VRC.SDKBase;

[UdonBehaviourSyncMode(BehaviourSyncMode.Manual)]
public class MaterialFloatSlider : UdonSharpBehaviour
{
    [Header("Implementation")]
    [SerializeField] Material linkedMaterial;
    [SerializeField] string propertyName;
    [SerializeField] float min;
    [SerializeField] float max;

    [Header("Prefab")]
    [SerializeField] TextMeshProUGUI minText;
    [SerializeField] TextMeshProUGUI maxText;
    [SerializeField] Slider slider;
    [SerializeField] TMP_InputField numericInput;

    [UdonSynced] float syncedValue;

    bool ignoreUpdates = false;

    private void Start()
    {
        ignoreUpdates = true;
        slider.minValue = min;
        slider.maxValue = max;
        ignoreUpdates = false;
        minText.text = min.ToString();
        maxText.text = max.ToString();
        
        float value = linkedMaterial.GetFloat(propertyName);
        slider.SetValueWithoutNotify(value);
        numericInput.SetTextWithoutNotify(value.ToString("F2"));
    }

    public override void OnDeserialization()
    {
        base.OnDeserialization();
        slider.SetValueWithoutNotify(syncedValue); // ToDo: Smoothing
        numericInput.SetTextWithoutNotify(syncedValue.ToString("F2")); // ToDo: Smoothing
        
        ApplyValue();
    }

    public void SliderInputUpdatedLocally()
    {
        if(ignoreUpdates)
            return;
        syncedValue = slider.value;
        numericInput.SetTextWithoutNotify(syncedValue.ToString("F2"));
        SyncAndApplyValue();
    }

    public void NumericInputUpdatedLocally()
    {
        if (ignoreUpdates)
            return;
        syncedValue = Mathf.Clamp(float.Parse(numericInput.text), min, max);
        numericInput.SetTextWithoutNotify(syncedValue.ToString("F2"));
        slider.SetValueWithoutNotify(syncedValue);
        SyncAndApplyValue();
    }

    void SyncAndApplyValue()
    {
        if (!Networking.IsOwner(gameObject))
            Networking.SetOwner(Networking.LocalPlayer, gameObject);

        RequestSerialization(); // ToDo: Slow down rate

        ApplyValue();
    }

    void ApplyValue()
    {
        linkedMaterial.SetFloat(propertyName, syncedValue);
    }
}
