Shader "Water/Simulation"
{

Properties
{
    [NoScaleOffset] _DisplacementTex ("Displacement Texture", 2D) = "white" {}
    _DisplacementClipping("Displacement Clipping", Range(0.0, 1.0)) = 0.03
    _S2("PhaseVelocity^2", Range(0.0, 0.5)) = 0.2
    [PowerSlider(0.01)]
    _Atten("Attenuation", Range(0.0, 1.0)) = 0.999
    _DeltaUV("Delta UV", Float) = 3
}

CGINCLUDE

#include "UnityCustomRenderTexture.cginc"

sampler2D _DisplacementTex;
float _DisplacementClipping;
half _S2;
half _Atten;
float _DeltaUV;

float4 frag(v2f_customrendertexture i) : SV_Target
{
    float2 uv = i.globalTexcoord;

    float du = 1.0 / _CustomRenderTextureWidth;
    float dv = 1.0 / _CustomRenderTextureHeight;
    float3 duv = float3(du, dv, 0) * _DeltaUV;

    float2 c = tex2D(_SelfTexture2D, uv);
    float p = (2 * c.r - c.g + _S2 * (
        tex2D(_SelfTexture2D, uv - duv.zy).r +
        tex2D(_SelfTexture2D, uv + duv.zy).r +
        tex2D(_SelfTexture2D, uv - duv.xz).r +
        tex2D(_SelfTexture2D, uv + duv.xz).r - 4 * c.r)) * _Atten;

    return float4(p, c.r, 0, 0);
}

float4 frag_push(v2f_customrendertexture i, float multiplier) : SV_Target {
    float displacement = tex2Dlod(_DisplacementTex, float4(i.localTexcoord.xy, 0, 0)).r;
    clip(displacement - _DisplacementClipping);
    return float4(displacement * multiplier, 0, 0, 0);
}

float4 frag_push_down(v2f_customrendertexture i) : SV_Target
{
    return frag_push(i, -1.0);
}

float4 frag_push_up(v2f_customrendertexture i) : SV_Target
{
    return frag_push(i, 1.0);
}

ENDCG

SubShader
{
    Cull Off ZWrite Off ZTest Always

    Pass
    {
        Name "Update"
        CGPROGRAM
        #pragma vertex CustomRenderTextureVertexShader
        #pragma fragment frag
        ENDCG
    }

    Pass
    {
        Name "PushDown"
        CGPROGRAM
        #pragma vertex CustomRenderTextureVertexShader
        #pragma fragment frag_push_down
        ENDCG
    }

    Pass
    {
        Name "PushUp"
        CGPROGRAM
        #pragma vertex CustomRenderTextureVertexShader
        #pragma fragment frag_push_up
        ENDCG
    }
}

}