#ifndef RAYMARCH_HELPERS_INCLUDED
#define RAYMARCH_HELPERS_INCLUDED

struct appdata
{
	float4 vertex : POSITION;
};

struct v2f
{
	float4 pos : SV_POSITION;
	float3 localPos : TEXCOORD0;
	float3 cameraPos : TEXCOORD1;
};

float3 getNormal(float3 p)
{
	float2 e = float2(0.001, 0.0);
	
	float3 n = float3(
		mainSDF(p + e.xyy) - mainSDF(p - e.xyy),
		mainSDF(p + e.yxy) - mainSDF(p - e.yxy),
		mainSDF(p + e.yyx) - mainSDF(p - e.yyx)
	);
	
	return normalize(n);
}

v2f vert (appdata v)
{
	v2f o;
	o.pos = UnityObjectToClipPos(v.vertex);
	o.localPos = v.vertex.xyz;
	o.cameraPos = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1.0)).xyz;
	return o;
}

half4 frag (v2f i) : SV_Target
{
	float3 ray = i.localPos - i.cameraPos;
	float3 rayDir = normalize(ray);
	float maxDistance = length(ray);
	float3 rayOrigin = i.cameraPos;

	float currentDistance = 0;
	for (int step = 0; step < 64; step++)
	{
		float3 p = rayOrigin + rayDir * currentDistance;
		float distanceToShape = mainSDF(p);

		if (distanceToShape < 0.001)
		{
			float3 n = getNormal(p); // The "Universal" way
			float3 lightDir = normalize(float3(1, 1, -1));
			float diff = max(0.2, dot(n, lightDir));
			return _Color * diff;
		}

		currentDistance += distanceToShape;
		if (currentDistance > maxDistance) break;
	}

	discard;
	return 0;
}

#endif