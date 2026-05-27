
using UdonSharp;
using UnityEngine;
using VRC.SDKBase;
using VRC.Udon;

public class CustomRenderTextureController : UdonSharpBehaviour
{
    [SerializeField] CustomRenderTexture linkedRenderTexture;

    public void ResetRenderTexture()
    {
        linkedRenderTexture.Initialize();

        SendCustomEvent(nameof(ResetRenderTextureRemote));
    }

    public void ResetRenderTextureRemote()
    {
        linkedRenderTexture.Initialize();
    }
}
