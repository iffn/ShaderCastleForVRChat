
using TMPro;
using UdonSharp;
using UnityEngine;
using VRC.SDKBase;
using UnityEngine.UI;
using VRC.Udon;

public class MaterialRGBSlider : UdonSharpBehaviour
{
    [Header("Implementation")]
    [SerializeField] Material linkedMaterial;
    [SerializeField] string propertyName;

    [Header("Prefab")]
    [SerializeField] Slider sliderRed;
    [SerializeField] Slider sliderGreen;
    [SerializeField] Slider sliderBlue;
    [SerializeField] TMP_InputField numericInputRed;
    [SerializeField] TMP_InputField numericInputGreen;
    [SerializeField] TMP_InputField numericInputBlue;

    [UdonSynced] Color syncedColor;

    bool ignoreUpdates = false;

    private void Start()
    {
        Color initialColor = linkedMaterial.GetColor(propertyName);
        WriteToSliders(initialColor);
        WriteToNumericInputs(initialColor);
    }

    public override void OnDeserialization()
    {
        base.OnDeserialization();
        WriteToSliders(syncedColor); // ToDo: Smoothing
        WriteToNumericInputs(syncedColor); // ToDo: Smoothing

        ApplyValue();
    }

    public void SliderInputUpdatedLocally()
    {
        syncedColor.r = sliderRed.value;
        syncedColor.g = sliderGreen.value;
        syncedColor.b = sliderBlue.value;

        WriteToNumericInputs(syncedColor);

        SyncAndApplyValue();
    }

    public void NumericInputUpdatedLocally()
    {
        syncedColor.r = Mathf.Clamp(float.Parse(numericInputRed.text), 0f, 1f);
        syncedColor.g = Mathf.Clamp(float.Parse(numericInputGreen.text), 0f, 1f);
        syncedColor.b = Mathf.Clamp(float.Parse(numericInputBlue.text), 0f, 1f);

        WriteToNumericInputs(syncedColor); // Do because of clamp
        WriteToSliders(syncedColor);

        SyncAndApplyValue();
    }

    void WriteToSliders(Color color)
    {
        sliderRed.value = color.r;
        sliderGreen.value = color.g;
        sliderBlue.value = color.b;
    }

    void WriteToNumericInputs(Color color)
    {
        numericInputRed.SetTextWithoutNotify(color.r.ToString("F2"));
        numericInputGreen.SetTextWithoutNotify(color.g.ToString("F2"));
        numericInputBlue.SetTextWithoutNotify(color.b.ToString("F2"));
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
        linkedMaterial.SetColor(propertyName, syncedColor);
    }
}
