
using UdonSharp;
using UnityEngine;
using VRC.SDK3.Components;
using VRC.SDKBase;
using VRC.Udon;

[RequireComponent(typeof(VRCPickup))]
public class LightDirectionPickup : UdonSharpBehaviour
{
    [SerializeField] Transform arrow;
    [SerializeField] Transform arrowPoint;
    [SerializeField] Transform pickupPoint;
    [SerializeField] Transform origin;

    [SerializeField] float dropFactor = 3f;

    Material linkedMaterial;
    VRCPickup linkedPickup;
    float arrowDistance;

    void Start()
    {
        linkedPickup = transform.GetComponent<VRCPickup>();
        arrowDistance = arrow.localPosition.magnitude;
        linkedMaterial = transform.parent.parent.GetChild(0).GetComponent<MeshRenderer>().sharedMaterial;

        PositionArrowRelativeToPickup();
    }

    void Update()
    {
        if (linkedPickup.IsHeld)
        {
            if (Networking.IsOwner(gameObject) && transform.localPosition.magnitude > arrowDistance * dropFactor)
            {
                linkedPickup.Drop();
                
                MovePickupToArrow();

                SendCustomEventDelayedSeconds(nameof(MovePickupToArrow), 0.5f);
            }

            PositionArrowRelativeToPickup();
        }
    }

    void PositionArrowRelativeToPickup()
    {
        arrow.position = arrowPoint.position;
        arrow.localPosition = arrowDistance * arrow.localPosition.normalized;
        arrow.LookAt(origin);

        linkedMaterial.SetVector("_worldLightDirection", origin.position - transform.position);
    }

    public void MovePickupToArrow()
    {
        transform.SetPositionAndRotation(pickupPoint.position, pickupPoint.rotation);
    }

    public override void OnDeserialization()
    {
        base.OnDeserialization();

        PositionArrowRelativeToPickup();
    }

    public override void OnDrop()
    {
        base.OnDrop();
        transform.SetPositionAndRotation(pickupPoint.position, pickupPoint.rotation);
    }

}
