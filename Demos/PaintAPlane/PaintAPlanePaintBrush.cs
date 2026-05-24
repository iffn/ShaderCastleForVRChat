
using UdonSharp;
using UnityEngine;
using VRC.SDK3.Components;
using VRC.SDKBase;
using VRC.Udon;

public class PaintAPlanePaintBrush : UdonSharpBehaviour
{
    [SerializeField] Material linkedMaterial;
    [SerializeField] string positionName = "_brushPositionLocal";

    VRCPickup linkedPickup;

    void Start()
    {
        linkedPickup = GetComponent<VRCPickup>();
    }

    void Update()
    {
        linkedMaterial.SetVector(positionName, new Vector4(transform.localPosition.x, transform.localPosition.y, transform.localPosition.z, 0f));
    }
}
