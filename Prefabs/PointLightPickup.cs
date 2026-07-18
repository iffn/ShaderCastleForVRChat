
using UdonSharp;
using UnityEngine;
using VRC.SDK3.Components;
using VRC.SDKBase;
using VRC.Udon;

[RequireComponent(typeof(VRCPickup))]
public class PointLightPickup : UdonSharpBehaviour
{
    [SerializeField] MeshRenderer linkedMeshRenderer;

    [SerializeField] Vector3 maxOffset;

    VRCPickup linkedPickup;
    Material linkedMaterial;
    string propertyname = "_pointLightWorldPosition";

    void Start()
    {
        linkedPickup = transform.GetComponent<VRCPickup>();

        maxOffset = new Vector3(Mathf.Abs(maxOffset.x), Mathf.Abs(maxOffset.y), Mathf.Abs(maxOffset.z));

        linkedMaterial = linkedMeshRenderer.sharedMaterial;
    }

    void Update()
    {
        if (linkedPickup.IsHeld)
        {
            if (Networking.IsOwner(gameObject))
            {
                if(Mathf.Abs(transform.localPosition.x) > maxOffset.x ||
                    Mathf.Abs(transform.localPosition.y) > maxOffset.y ||
                    Mathf.Abs(transform.localPosition.z) > maxOffset.z)
                {
                    linkedPickup.Drop();
                    transform.localPosition = 0.99f * new Vector3(
                        Mathf.Clamp(transform.localPosition.x, -maxOffset.x, maxOffset.x),
                        Mathf.Clamp(transform.localPosition.y, -maxOffset.y, maxOffset.y),
                        Mathf.Clamp(transform.localPosition.z, -maxOffset.z, maxOffset.z));
                }

            }

            linkedMaterial.SetVector(propertyname, transform.position);
        }
    }

    public override void OnDeserialization()
    {
        base.OnDeserialization();

        linkedMaterial.SetVector(propertyname, transform.position);
    }
}
