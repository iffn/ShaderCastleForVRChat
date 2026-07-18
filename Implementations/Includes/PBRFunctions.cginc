#ifndef SHADERCASTLE_PBR_FUNCTIONS_INCLUDED
#define SHADERCASTLE_PBR_FUNCTIONS_INCLUDED

#define PI 3.14159265
#define ONE_OVER_PI 0.31830988618
#define PIx4 12.56637061435917295

float3 FresnelReflectionWithSchlickApproximationBRDF(float VdotH01, float3 albedo, float metallic)
{
	float specularReflectanceNonMetallic = 0.04; // Standard value for non-metals. Actually ((IoR-1)/(IoR+1))^2, IOR = Index of Refraction
	float3 f0 = lerp(specularReflectanceNonMetallic, albedo, metallic);

	return f0 + (1.0 - f0) * pow(1.0 - VdotH01, 5.0);
}

float3 fresnelReflectionWithSchlickApproximationAmbient(float3 albedo, float metallic, float roughness, float NdotV01)
{
	float specularReflectanceNonMetallic = 0.04;
	float3 specularReflectanceNormal = lerp(specularReflectanceNonMetallic, albedo, metallic);
	float3 specularReflectanceGrazing = max(1.0 - roughness, specularReflectanceNormal);
	return specularReflectanceNormal + (specularReflectanceGrazing - specularReflectanceNormal) * pow(1.0 - NdotV01, 5.0);
}

float GGXNormalDistributionFunction(float NdotH01, float roughnessSquared)
{
	float roughnesPow4 = roughnessSquared * roughnessSquared;
	float base = (NdotH01 * NdotH01) * (roughnesPow4 - 1) + 1;
	return roughnesPow4 / (PI * base * base);
}

float MicrofacetMaskingGeometryWithSchlickGGXApproximation(float NdotV01, float NdotL01, float roughnessSquared)
{
	float floatRoughnessSquared = roughnessSquared * 0.5;
	float floatRoughnessSquaredInverse = 1 - floatRoughnessSquared;

	float geometryTermView = NdotV01 / (NdotV01 * floatRoughnessSquaredInverse + floatRoughnessSquared);
	float geometryTermLight = NdotL01 / (NdotL01 * floatRoughnessSquaredInverse + floatRoughnessSquared);
	
	return geometryTermView * geometryTermLight;
}

float3 microfacetBRDF(float3 normal, float3 viewDir, float3 lightVector, float NdotV01, float NdotL01, float3 albedo, float roughness, float metallic)
{
	float3 floatVectorLightView = normalize(viewDir + lightVector);
	
	float NdotH01 = saturate(dot(normal, floatVectorLightView));
	float VdotH01 = saturate(dot(viewDir, floatVectorLightView));
	
	float3 fresnelReflection = FresnelReflectionWithSchlickApproximationBRDF(VdotH01, albedo, metallic);
	float roughnessSquared = roughness * roughness;
	float normalDistribution = GGXNormalDistributionFunction(NdotH01, roughnessSquared);
	float microfacetMasking = MicrofacetMaskingGeometryWithSchlickGGXApproximation(NdotV01, NdotL01, roughnessSquared);
	
	float divisor = max(4.0 * NdotL01 * NdotV01, 0.0001); // Preventing division by 0 errors. In this case, the specularBRDF would evaluate to 0 / 0.0001 = 0
	float3 specularBRDF = (fresnelReflection * normalDistribution * microfacetMasking) / divisor;
	
	float3 remainingDiffuseEnergy = 1.0 - fresnelReflection;
	float3 diffuseSubstrateFactor = albedo * remainingDiffuseEnergy * (1.0 - metallic);
	float3 diffuseBRDF = diffuseSubstrateFactor * ONE_OVER_PI;
	
	return diffuseBRDF + specularBRDF;
}

float3 SampleReflectionProbe(float3 viewVector, float3 worldNormal, float roughness)
{
	float3 reflectionVector = reflect(-viewVector, worldNormal);
	float mipLevel = roughness * 6.0; 
	float4 encodedReflection = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, reflectionVector, mipLevel);
	return DecodeHDR(encodedReflection, unity_SpecCube0_HDR);
}

#endif