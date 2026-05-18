
using UdonSharp;
using UnityEngine;
using VRC.SDKBase;
using VRC.Udon;

public class SetActiveToggle : UdonSharpBehaviour
{
    [SerializeField] GameObject reference;

    public void Toggle()
    {
        reference.SetActive(!reference.activeSelf);
    }
}
