Shader "Water/Surface" 
{

Properties
{
    _Color("Color", color) = (1, 1, 1, 0)
    _DispTex("Disp Texture", 2D) = "gray" {}
    _Glossiness ("Smoothness", Range(0,1)) = 0.5
    _Metallic ("Metallic", Range(0,1)) = 0.0
    _MinDist("Min Distance", Range(0.1, 50)) = 10
    _MaxDist("Max Distance", Range(0.1, 50)) = 25
    _TessFactor("Tessellation", Range(1, 100)) = 10
    _Displacement("Displacement", Range(0, 1.0)) = 0.3
    _Lod("Lod", Range(0, 4)) = 1
}

SubShader
{

Tags { "Queue" = "Transparent" "RenderType" = "Transparent" }

CGPROGRAM

#pragma surface surf Standard alpha addshadow fullforwardshadows vertex:disp tessellate:tessDistance
#pragma target 5.0
#include "Tessellation.cginc"

float _TessFactor;
float _Displacement;
float _MinDist;
float _MaxDist;
sampler2D _DispTex;
float4 _DispTex_TexelSize;
fixed4 _Color;
half _Glossiness;
half _Metallic;
float _Lod;

struct appdata 
{
    float4 vertex   : POSITION;
    float4 tangent  : TANGENT;
    float3 normal   : NORMAL;
    float2 texcoord : TEXCOORD0;
};

struct Input 
{
    float2 uv_DispTex;
};

float4 tessDistance(appdata v0, appdata v1, appdata v2) 
{
    return UnityDistanceBasedTess(v0.vertex, v1.vertex, v2.vertex, _MinDist, _MaxDist, _TessFactor);
}

void disp(inout appdata v)
{
    float displacement = tex2Dlod(_DispTex, float4(v.texcoord.xy, 0, _Lod)).r;
    //float d =  sign(displacement) * sqrt(abs(displacement)) * _Displacement;
    float d =  displacement * _Displacement;
    v.vertex.xyz += v.normal * d;
}

void surf(Input IN, inout SurfaceOutputStandard o) 
{
    o.Albedo = _Color.rgb;
    o.Metallic = _Metallic;
    o.Smoothness = _Glossiness;
    o.Alpha = _Color.a * (0.5 + 0.5 * clamp(tex2D(_DispTex, IN.uv_DispTex).r, 0, 1));

    float3 duv = float3(_DispTex_TexelSize.xy, 0);
    half v1 = tex2Dlod(_DispTex, float4(IN.uv_DispTex - duv.xz, 0, _Lod)).y;
    half v2 = tex2Dlod(_DispTex, float4(IN.uv_DispTex + duv.xz, 0, _Lod)).y;
    half v3 = tex2Dlod(_DispTex, float4(IN.uv_DispTex - duv.zy, 0, _Lod)).y;
    half v4 = tex2Dlod(_DispTex, float4(IN.uv_DispTex + duv.zy, 0, _Lod)).y;
    o.Normal = normalize(float3(v1 - v2, v3 - v4, 0.3));
}

ENDCG

}

FallBack "Diffuse"

}