
using UdonSharp;
using UnityEngine;
using UnityEngine.UI;
using TMPro;
using VRC.SDKBase;
using VRC.Udon;

[UdonBehaviourSyncMode(BehaviourSyncMode.Manual)]
public class TextureScaleAndOffsetUI : UdonSharpBehaviour
{
    [Header("Implementation")]
    [SerializeField] Material linkedMaterial;
    [SerializeField] string propertyName;

    [Header("Prefab")]
    [SerializeField] Slider scaleXSlider;
    [SerializeField] Slider scaleYSlider;
    [SerializeField] Slider offsetXSlider;
    [SerializeField] Slider offsetYSlider;
    [SerializeField] TMP_InputField scaleXInput;
    [SerializeField] TMP_InputField scaleYInput;
    [SerializeField] TMP_InputField offsetXInput;
    [SerializeField] TMP_InputField offsetYInput;

    [UdonSynced] Vector2 offset;
    [UdonSynced] Vector2 scale;

    void Start()
    {
        scale.x = scaleXSlider.value;
        scale.y = scaleYSlider.value;
        offset.x = offsetXSlider.value;
        offset.y = offsetYSlider.value;
        
        scale.x = Mathf.Clamp(int.Parse(scaleXInput.text), scaleXSlider.minValue, scaleXSlider.maxValue);
        scale.y = Mathf.Clamp(int.Parse(scaleYInput.text), scaleYSlider.minValue, scaleYSlider.maxValue);
        offset.x = Mathf.Clamp(int.Parse(offsetXInput.text), offsetXSlider.minValue, offsetXSlider.maxValue);
        offset.y = Mathf.Clamp(int.Parse(offsetYInput.text), offsetYSlider.minValue, offsetYSlider.maxValue);
    }

    public void SliderInputUpdatedLocally()
    {
        scale.x = scaleXSlider.value;
        scale.y = scaleYSlider.value;
        offset.x = offsetXSlider.value;
        offset.y = offsetYSlider.value;

        scaleXInput.SetTextWithoutNotify(scale.x.ToString("F2"));
        scaleYInput.SetTextWithoutNotify(scale.y.ToString("F2"));
        offsetXInput.SetTextWithoutNotify(offset.x.ToString("F2"));
        offsetYInput.SetTextWithoutNotify(offset.y.ToString("F2"));

        SyncAndApplyValue();
    }

    public void NumericInputUpdatedLocally()
    {
        scale.x = Mathf.Clamp(float.Parse(scaleXInput.text), scaleXSlider.minValue, scaleXSlider.maxValue);
        scale.y = Mathf.Clamp(float.Parse(scaleYInput.text), scaleYSlider.minValue, scaleYSlider.maxValue);
        offset.x = Mathf.Clamp(float.Parse(offsetXInput.text), offsetXSlider.minValue, offsetXSlider.maxValue);
        offset.y = Mathf.Clamp(float.Parse(offsetYInput.text), offsetYSlider.minValue, offsetYSlider.maxValue);

        scaleXSlider.SetValueWithoutNotify(scale.x);
        scaleYSlider.SetValueWithoutNotify(scale.y);
        offsetXSlider.SetValueWithoutNotify(offset.x);
        offsetYSlider.SetValueWithoutNotify(offset.y);

        scaleXInput.SetTextWithoutNotify(scale.x.ToString("F2"));
        scaleYInput.SetTextWithoutNotify(scale.y.ToString("F2"));
        offsetXInput.SetTextWithoutNotify(offset.x.ToString("F2"));
        offsetYInput.SetTextWithoutNotify(offset.y.ToString("F2"));

        SyncAndApplyValue();
    }

    public override void OnDeserialization()
    {
        base.OnDeserialization();

        scaleXSlider.SetValueWithoutNotify(scale.x);
        scaleYSlider.SetValueWithoutNotify(scale.y);
        offsetXSlider.SetValueWithoutNotify(offset.x);
        offsetYSlider.SetValueWithoutNotify(offset.y);

        scaleXInput.SetTextWithoutNotify(scale.x.ToString("F2"));
        scaleYInput.SetTextWithoutNotify(scale.y.ToString("F2"));
        offsetXInput.SetTextWithoutNotify(offset.x.ToString("F2"));
        offsetYInput.SetTextWithoutNotify(offset.y.ToString("F2"));
        
        ApplyValue();
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
        linkedMaterial.SetTextureOffset(propertyName, offset);
        linkedMaterial.SetTextureScale(propertyName, scale);
    }
}
