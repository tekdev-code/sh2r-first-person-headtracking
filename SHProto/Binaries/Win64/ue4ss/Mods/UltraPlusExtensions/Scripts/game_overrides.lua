local SettingsCore = require('settings.core')
local IniReader = require('modules.ini_reader')
local SilentHillOverrides = {}

-- Whitelist only the settings this game needs
SilentHillOverrides.allowedSettings = {
    'BetterReflectionSDFs',
    'Bloom',
    'ChromaticAberration',
    'Denoiser',
    'DepthOfField',
    'EnableKeybinds',
    'ExtendedFogQuality',
    'FOV',
    'Fog',
    'VolumetricFog',
    'LODBias',
    'LODDistanceScale',
    'LightingAO',
    'LightingResolution',
    'LightingMode',
    'LightingQuality',
    'LightingUpdateSpeed',
    'LumenTraceDistance',
    'MotionBlur',
    'ReduceInputLatency',
    'ReflectionQuality',
    'ReflectionBias',
    'Sharpness',
    'HighQualityTracing',
    'RayTracingCullingRadius',
    'Reflex',
    'Vignette',
    'VSync',
    'LumenDiffuseColorBoost',
    'LightDrawDistance',
    'ScreenSpaceReflections',
    'FilmGrain',
    'DynamicFPS',
    'FogDOF',
    'RaytracingMode',
    'RTShadows',
    'FixFlickeringFoliage',
    'AutoApplyConfig'
}

-- Game-specific custom settings
SilentHillOverrides.customSettings = {
    ScreenSpaceReflections = SettingsCore.createSetting({
        name = 'ScreenSpaceReflections',
        type = SettingsCore.Types.ENUM,
        comment = 'game/off/on; controls screen space tracing for Lumen reflections',
        default = 'game',
        values = {'game', 'off', 'on'},
        gameDefaultCvars = {'r.Lumen.Reflections.ScreenTraces'},
        commands = {
            GAME = {},
            OFF = {
                {'r.Lumen.Reflections.ScreenTraces', '0'}
            },
            ON = {
                {'r.Lumen.Reflections.ScreenTraces', '1'}
            }
        }
    }),

    FogDOF = SettingsCore.createSetting({
        name = 'FogDOF',
        type = SettingsCore.Types.ENUM,
        comment = 'game/off/on; fog depth of field',
        default = 'game',
        values = {'game', 'off', 'on'},
        gameDefaultCvars = {'r.Atmosphere.DepthOfFieldDepthBlurRadiusScale'},
        commands = {
            GAME = {},
            OFF = {
                {'r.Atmosphere.DepthOfFieldDepthBlurRadiusScale', '0'}
            },
            ON = {
                {'r.Atmosphere.DepthOfFieldDepthBlurRadiusScale', '1'}
            }
        },
        ignoreCache = true
    }),

    RaytracingMode = SettingsCore.createSetting({
        name = 'RaytracingMode',
        type = SettingsCore.Types.ENUM,
        comment = 'game/off/simple/detailed; toggle between raytracing off, simple raytracing and detailed raytracing, detailed is much more expensive',
        default = 'game',
        values = {'game', 'off', 'simple', 'detailed'},
        gameDefaultCvars = {'r.RayTracing', 'r.Lumen.HardwareRaytracing', 'r.GFX.ReflectionMode'},
        commands = {
            GAME = {},
            OFF = {
                {'r.RayTracing', '0'},
                {'r.Lumen.HardwareRaytracing', '0'},
                {'r.GFX.ReflectionMode', '0'}
            },
            SIMPLE = {
                {'r.RayTracing', '1'},
                {'r.Lumen.HardwareRaytracing', '1'},
                {'r.GFX.ReflectionMode', '0'}
            },
            DETAILED = {
                {'r.RayTracing', '1'},
                {'r.Lumen.HardwareRaytracing', '1'},
                {'r.GFX.ReflectionMode', '1'}
            }
        }
    }),

    LumenDiffuseColorBoost = SettingsCore.createSetting({
        name = 'LumenDiffuseColorBoost',
        type = SettingsCore.Types.NUMERIC,
        valueType = 'float',
        comment = 'Boost particularly local light sources in diffuse intensity (0.0-5.0, game = use game default)',
        default = 'game',
        gameDefault = 'game',
        category = 'Advanced',
        min = 0,
        max = 5,
        step = 0.05,
        applyCustom = function(self, setCustomFunc)
            local PostProcessVolumeModule = require('modules.postprocess_volume')
            PostProcessVolumeModule.setPPVUpdateFlag(true)
        end
    }),

    RTShadows = SettingsCore.createSetting({
        name = 'RTShadows',
        type = SettingsCore.Types.ENUM,
        comment = 'game/on; enables ray-traced shadows - must use with RTShadows addon',
        default = 'game',
        values = {'game', 'on'},
        gameDefaultCvars = {'r.RayTracing.Shadows', 'r.Shadow.Virtual.Enable', 'r.RayTracing.Culling.Angle', 'r.RayTracing.Geometry.InstancedStaticMeshes.CullAngle', 'r.Raytracing.Nanite.Mode'},
        commands = {
            GAME = {},
            ON = {
                {'r.RayTracing.Shadows', '1'},
                {'r.Shadow.Virtual.Enable', '1'},
                {'r.RayTracing.Culling.Angle', '0.3'},
                {'r.RayTracing.Geometry.InstancedStaticMeshes.CullAngle', '1'},
                {'r.Raytracing.Nanite.Mode', '1'}
            }
        }
    }),

    FixFlickeringFoliage = SettingsCore.createSetting({
        name = 'FixFlickeringFoliage',
        type = SettingsCore.Types.ENUM,
        comment = 'game/on; fixes flickering foliage but causes light leakage particularly near windows',
        default = 'game',
        values = {'game', 'on'},
        gameDefaultCvars = {'r.Lumen.ScreenProbeGather.ScreenTraces.HZBTraversal'},
        commands = {
            GAME = {},
            ON = {
                {'r.Lumen.ScreenProbeGather.ScreenTraces.HZBTraversal', '0'}
            }
        }
    })
}

SilentHillOverrides.WeightedSettings = {
    {name = 'ReflectionQuality', weights = {high = 0, veryhigh = -1.7, epic = -3.5, insane = -8}},
    {name = 'LightingResolution', weights = {mediumhigh = 2, high = 0, veryhigh = -1.5, epic = -3}},
    {name = 'LightingQuality', weights = {standard = 0, high = -0.7, veryhigh = -2, epic = -3.5, insane = -6}}
}

-- Modify existing settings after modules are loaded
SilentHillOverrides.modifySettings = function(SettingsManager)
    SettingsManager.settings.LODBias.presets = {low = 'off', medium = 'off', high = 'minuspoint5', veryhigh = 'minuspoint5', epic = 'minuspoint5'}
    SettingsManager.settings.BetterReflectionSDFs.presets = {low = 'off', medium = 'off', high = 'off', veryhigh = 'on', epic = 'on', raytracing = 'off'}
    SettingsManager.settings.HighQualityTracing.presets = {low = 'off', medium = 'off', high = 'on', veryhigh = 'on', epic = 'on'}
    SettingsManager.settings.LODDistanceScale.presets = {low = 'game', medium = 'high', high = 'veryhigh', veryhigh = 'epic', epic = 'ultra'}
    SettingsManager.settings.LightingQuality.presets = {low = 'standard', medium = 'standard', high = 'high', veryhigh = 'veryhigh', epic = 'epic'}
    SettingsManager.settings.LightingResolution.presets = {low = 'high', medium = 'high', high = 'veryhigh', veryhigh = 'veryhigh', epic = 'epic'}
    SettingsManager.settings.LightingUpdateSpeed.presets = {low = 'default', medium = 'high', high = 'high', veryhigh = 'high', epic = 'epic'}
    SettingsManager.settings.LightingAO.presets = {low = 'lumen_less_noise', medium = 'lumen_less_noise', high = 'lumen_less_noise', veryhigh = 'lumen_less_noise', epic = 'lumen_less_noise'}
    SettingsManager.settings.LumenTraceDistance.presets = {low = 20000.0, medium = 20000.0, high = 20000.0, veryhigh = 20000.0, epic = 25000.0}
    SettingsManager.settings.ReflectionQuality.presets = {low = 'game', medium = 'high', high = 'high', veryhigh = 'veryhigh', epic = 'veryhigh'}
    SettingsManager.settings.RayTracingCullingRadius.presets = {low_raytracing = 5000, medium_raytracing = 7500, high_raytracing = 10000, veryhigh_raytracing = 15000, epic_raytracing = 15000}

    SettingsManager.settings.ExtendedShadowQuality.comment = 'game/high/epic/ultra/insane; epic is the same as in game epic'
    SettingsManager.settings.ExtendedShadowQuality.default = 'game'
    SettingsManager.settings.ExtendedShadowQuality.values = {'game', 'high', 'epic', 'ultra', 'insane'}
    SettingsManager.settings.ExtendedShadowQuality.gameDefaultCvars = {'r.Shadow.Virtual.ResolutionLodBiasDirectional', 'r.Shadow.Virtual.ResolutionLodBiasDirectionalMoving'}
    SettingsManager.settings.ExtendedShadowQuality.commands = {
        GAME = {},
        HIGH = {
            {'r.Shadow.Virtual.ResolutionLodBiasDirectional', '-0.5'},
            {'r.Shadow.Virtual.ResolutionLodBiasDirectionalMoving', '-0.5'}
        },
        EPIC = {
            {'r.Shadow.Virtual.ResolutionLodBiasDirectional', '-1'},
            {'r.Shadow.Virtual.ResolutionLodBiasDirectionalMoving', '-1'}
        },
        ULTRA = {
            {'r.Shadow.Virtual.ResolutionLodBiasDirectional', '-1.5'},
            {'r.Shadow.Virtual.ResolutionLodBiasDirectionalMoving', '-1.5'}
        },
        INSANE = {
            {'r.Shadow.Virtual.ResolutionLodBiasDirectional', '-2'},
            {'r.Shadow.Virtual.ResolutionLodBiasDirectionalMoving', '-1.5'}
        }
    }

    SettingsManager.settings.ReflectionQuality.commands = {
        GAME = {},
        HIGH = {
            {'r.Lumen.Reflections.MaxRoughnessToTrace', '0.4'},
            {'r.Lumen.Reflections.MaxRoughnessToTraceForFoliage', '0.36'},
            {'r.Lumen.Reflections.DownsampleFactor', '1'}
        },
        VERYHIGH = {
            {'r.Lumen.Reflections.MaxRoughnessToTrace', '0.50'},
            {'r.Lumen.Reflections.MaxRoughnessToTraceForFoliage', '0.4'},
            {'r.Lumen.Reflections.DownsampleFactor', '1'}
        },
        EPIC = {
            {'r.Lumen.Reflections.MaxRoughnessToTrace', '0.68'},
            {'r.Lumen.Reflections.MaxRoughnessToTraceForFoliage', '0.5'},
            {'r.Lumen.Reflections.DownsampleFactor', '1'}
        },
        INSANE = {
            {'r.Lumen.Reflections.MaxRoughnessToTrace', '0.8'},
            {'r.Lumen.Reflections.MaxRoughnessToTraceForFoliage', '0.6'},
            {'r.Lumen.Reflections.DownsampleFactor', '1'}
        }
    }

    SettingsManager.settings.HighQualityTracing.gameDefaultCvars = {'r.Lumen.TraceMeshSDFs', 'r.Lumen.TraceMeshSDFs.Allow'}
    SettingsManager.settings.HighQualityTracing.commands = {
        GAME = {},
        OFF = {
            {'r.Lumen.TraceMeshSDFs', '0'}
        },
        ON = {
            {'r.Lumen.TraceMeshSDFs', '1'},
            {'r.Lumen.TraceMeshSDFs.Allow', '1'}
        }
    }

    SettingsManager.settings.LightingMode.comment = 'standard; no other lighting modes at this time'
    SettingsManager.settings.LightingMode.values = {'game', 'standard'}

    SettingsManager.settings.LightingAO.comment = 'lumen/lumen_less_noise/ssao/gtao; AO method - lumen is highest quality but may cause specular noise, lumen_less_noise will have less AO but will be cleaner and work better with lower settings'
    SettingsManager.settings.LightingAO.default = 'lumen_less_noise'
    SettingsManager.settings.LightingAO.values = {'lumen', 'lumen_less_noise', 'ssao', 'gtao'}

    SettingsManager.settings.Fog.comment = 'game/off/on; fog mode control'
    SettingsManager.settings.Fog.values = {'game', 'off', 'on'}
    SettingsManager.settings.Fog.gameDefaultCvars = {'r.Fog'}
    SettingsManager.settings.Fog.commands = {
        GAME = {},
        OFF = {
            {'r.Fog', '0'}
        },
        ON = {
            {'r.Fog', '1'}
        }
    }

    SettingsManager.settings.Denoiser.comment = "!game/none/none_temporalgihigh/temporal/temporal_high/rayreconstruction/rayreconstruction_temporalgihigh; primarily controls reflection denoising and some GI denoising, default of game is overridden by U+ to disable reflection a reflection denoising component, AMD users may need to explicitly set temporal, temporalgihigh variants preferable for DLSS 4.5"
    SettingsManager.settings.Denoiser.commands = {
        GAME = {},
        NONE = {
            {'r.NGX.DLSS.DenoiserMode', '0'},
            {'r.Lumen.Reflections.Temporal', '0'},
            {'r.Lumen.Reflections.Temporal.MaxFramesAccumulated', '16'},
            {'r.Lumen.Reflections.Temporal.DistanceThreshold', '0.0'},
            {'r.Lumen.ScreenProbeGather.Temporal.MaxFramesAccumulated', '16'},
            {'r.Lumen.ScreenProbeGather.Temporal.DistanceThreshold', '0.005'},
            {'r.Lumen.Reflections.BilateralFilter', '1'},
            {'r.Shadow.Virtual.SMRT.RayCountDirectional', '8'},
            {'r.Shadow.Virtual.SMRT.RayCountLocal', '8'},
            {'r.NGX.DLSS.DenoiserMode', '0'}
        },
        NONE_TEMPORALGIHIGH = {
            {'r.NGX.DLSS.DenoiserMode', '0'},
            {'r.Lumen.Reflections.Temporal', '0'},
            {'r.Lumen.Reflections.Temporal.MaxFramesAccumulated', '20'},
            {'r.Lumen.Reflections.Temporal.DistanceThreshold', '0.0'},
            {'r.Lumen.ScreenProbeGather.Temporal.MaxFramesAccumulated', '20'},
            {'r.Lumen.ScreenProbeGather.Temporal.DistanceThreshold', '0.01'},
            {'r.Lumen.Reflections.BilateralFilter', '1'},
            {'r.Shadow.Virtual.SMRT.RayCountDirectional', '8'},
            {'r.Shadow.Virtual.SMRT.RayCountLocal', '8'},
            {'r.NGX.DLSS.DenoiserMode', '0'}
        },
        TEMPORAL = {
            {'r.NGX.DLSS.DenoiserMode', '0'},
            {'r.Lumen.Reflections.Temporal', '1'},
            {'r.Lumen.Reflections.Temporal.MaxFramesAccumulated', '16'},
            {'r.Lumen.Reflections.Temporal.DistanceThreshold', '0.03'},
            {'r.Lumen.ScreenProbeGather.Temporal.MaxFramesAccumulated', '16'},
            {'r.Lumen.ScreenProbeGather.Temporal.DistanceThreshold', '0.005'},
            {'r.Lumen.Reflections.BilateralFilter', '1'},
            {'r.Shadow.Virtual.SMRT.RayCountDirectional', '8'},
            {'r.Shadow.Virtual.SMRT.RayCountLocal', '8'},
            {'r.NGX.DLSS.DenoiserMode', '0'}
        },
        TEMPORAL_HIGH = {
            {'r.NGX.DLSS.DenoiserMode', '0'},
            {'r.Lumen.Reflections.Temporal', '1'},
            {'r.Lumen.Reflections.Temporal.MaxFramesAccumulated', '20'},
            {'r.Lumen.Reflections.Temporal.DistanceThreshold', '0.03'},
            {'r.Lumen.ScreenProbeGather.Temporal.MaxFramesAccumulated', '20'},
            {'r.Lumen.ScreenProbeGather.Temporal.DistanceThreshold', '0.01'},
            {'r.Lumen.Reflections.BilateralFilter', '1'},
            {'r.Shadow.Virtual.SMRT.RayCountDirectional', '8'},
            {'r.Shadow.Virtual.SMRT.RayCountLocal', '8'},
            {'r.NGX.DLSS.DenoiserMode', '0'}
        },
        RAYRECONSTRUCTION = {
            {'r.NGX.DLSS.DenoiserMode', '1'},
            {'r.Lumen.Reflections.Temporal', '0'},
            {'r.Lumen.Reflections.Temporal.MaxFramesAccumulated', '4'},
            {'r.Lumen.Reflections.BilateralFilter', '0'},
            {'r.Lumen.Reflections.Temporal.DistanceThreshold', '0.0'},
            {'r.Lumen.ScreenProbeGather.Temporal.MaxFramesAccumulated', '16'},
            {'r.Lumen.ScreenProbeGather.Temporal.DistanceThreshold', '0.005'},
            {'r.Shadow.Virtual.SMRT.RayCountDirectional', '4'},
            {'r.Shadow.Virtual.SMRT.RayCountLocal', '4'},
            {'r.NGX.DLSS.DenoiserMode', '1'}
        },
        RAYRECONSTRUCTION_TEMPORALGIHIGH = {
            {'r.NGX.DLSS.DenoiserMode', '1'},
            {'r.Lumen.Reflections.Temporal', '0'},
            {'r.Lumen.Reflections.Temporal.MaxFramesAccumulated', '4'},
            {'r.Lumen.Reflections.BilateralFilter', '0'},
            {'r.Lumen.Reflections.Temporal.DistanceThreshold', '0.0'},
            {'r.Lumen.ScreenProbeGather.Temporal.MaxFramesAccumulated', '20'},
            {'r.Lumen.ScreenProbeGather.Temporal.DistanceThreshold', '0.01'},
            {'r.Shadow.Virtual.SMRT.RayCountDirectional', '4'},
            {'r.Shadow.Virtual.SMRT.RayCountLocal', '4'},
            {'r.NGX.DLSS.DenoiserMode', '1'}
        }
    }
end

-- Custom functions for game-specific logic
SilentHillOverrides.customFunctions = {
    applyLightingMode = {
        func = function(mode, setCVar)
            setCVar('r.LumenScene.Radiosity.MaxRayIntensity', '10')
            setCVar('r.Lumen.ScreenProbeGather.MaxRayIntensity', '10')
            setCVar('r.Lumen.ScreenProbeGather.RadianceCache.ReprojectionRadiusScale', '1.5')
            setCVar('r.Lumen.ScreenProbeGather.RadianceCache.NumProbesToTraceBudget', '150')

            setCVar('r.Lumen.ScreenProbeGather.Temporal', '1')
            setCVar('r.Lumen.ScreenProbeGather.Temporal.RelativeSpeedDifferenceToConsiderLightingMoving', '0.0035')
            setCVar('r.Lumen.ScreenProbeGather.Temporal.DistanceThreshold', '0.005')
            setCVar('r.Lumen.ScreenProbeGather.Temporal.FastUpdateModeUseNeighborhoodClamp', '0') -- more flicker
            setCVar('r.Lumen.ScreenProbeGather.ImportanceSample.MinPDFToTrace', '0.25')

            setCVar('r.Lumen.ScreenProbeGather.AdaptiveProbeMinDownsampleFactor', '2')

            setCVar('r.Lumen.ScreenProbeGather.TemporalFilterProbes', '1')
            setCVar('r.Lumen.ScreenProbeGather.SpatialFilterNumPasses', '3')
            setCVar('r.Lumen.ScreenProbeGather.SpatialFilterMaxRadianceHitAngle', '45')
            setCVar('r.Lumen.ScreenProbeGather.SpatialFilterPositionWeightScale', '500')
            setCVar('r.Lumen.ScreenProbeGather.FullResolutionJitterWidth', '1')
            setCVar('r.Lumen.ScreenProbeGather.Temporal.RejectBasedOnNormal', '0')
            setCVar('r.LumenScene.DirectLighting.OffscreenShadowing.TraceMeshSDFs', '1')
            
            if mode == 'standard' then
                setCVar('r.Lumen.ScreenProbeGather.DiffuseIntegralMethod', '0', true)
                setCVar('r.Lumen.ScreenProbeGather.ScreenSpaceBentNormal.SlopeCompareToleranceScale', '2.0')
                setCVar('r.Lumen.ScreenProbeGather.TwoSidedFoliageBackfaceDiffuse', '1')
            elseif mode == 'advanced' then
                setCVar('r.Lumen.ScreenProbeGather.DiffuseIntegralMethod', '1', true)
                setCVar('r.Lumen.ScreenProbeGather.ScreenSpaceBentNormal.ApplyDuringIntegration', '0', true)
                setCVar('r.Lumen.ScreenProbeGather.ScreenSpaceBentNormal.SlopeCompareToleranceScale', '1.5')
                setCVar('r.Lumen.ScreenProbeGather.TwoSidedFoliageBackfaceDiffuse', '0')
            end
        end,
        mode = 'replace'
    },
   
    applyLightingQuality = {
        func = function(quality, mode, setCVar, settings)
            local configs = {
                standard = {atlas = '128', grid = '48', probe = '32', mips = mode == 'advanced' and '3' or '1', texeldensity = '0.2', atlasres = '3072', adaptive = '0.6', octares = mode == 'advanced' and '16' or '8', feedbackres = '-0.5', cullingangle = '2', importancesample = '1'},
                high = {atlas = '128', grid = '48', probe = '32', mips = mode == 'advanced' and '3' or '1', texeldensity = '0.2', atlasres = '4096', adaptive = '0.6', octares = mode == 'advanced' and '16' or '8', feedbackres = '-0.5', cullingangle = '2', importancesample = '1'},
                veryhigh = {atlas = '128', grid = '48', probe = '32', mips = mode == 'advanced' and '3' or '1', texeldensity = '0.25', atlasres = '4096', adaptive = '0.65', octares = mode == 'advanced' and '16' or '8', feedbackres = '-0.25', cullingangle = '1', importancesample = '1'},
                epic = {atlas = '128', grid = '48', probe = '32', mips = mode == 'advanced' and '3' or '1', texeldensity = '0.3', atlasres = '4096', adaptive = '0.7', octares = mode == 'advanced' and '16' or '8', feedbackres = '0.0', cullingangle = '1', importancesample = '1'},
                insane = {atlas = '128', grid = '48', probe = '32', mips = mode == 'advanced' and '3' or '1', texeldensity = '0.4', atlasres = '4096', adaptive = '0.8', octares = mode == 'advanced' and '16' or '8', feedbackres = '0.0', cullingangle = '1', importancesample = '1'}
            }

            local config = configs[quality] or configs.standard
            --setCVar('r.LumenScene.Radiosity.HemisphereProbeResolution', config.radiosityhemi)
            --setCVar('r.LumenScene.Radiosity.ProbeSpacing', config.radiosityprobe)

            local rtshadows = settings.RTShadows

            if rtshadows and rtshadows.currentValue == 'on' then
                config.cullingangle = '0.3'
            end

            setCVar('r.RayTracing.Culling.Angle', config.cullingangle)
            setCVar('r.Lumen.ScreenProbeGather.ImportanceSample', config.importancesample)            
            setCVar('r.Lumen.ScreenProbeGather.TracingOctahedronResolution', config.octares)
            setCVar('r.Lumen.ScreenProbeGather.AdaptiveProbeAllocationFraction', config.adaptive)
            setCVar('r.Lumen.ScreenProbeGather.RadianceCache.ProbeAtlasResolutionInProbes', config.atlas)
            setCVar('r.Lumen.ScreenProbeGather.RadianceCache.GridResolution', config.grid)
            setCVar('r.Lumen.ScreenProbeGather.RadianceCache.ProbeResolution', config.probe)
            setCVar('r.Lumen.ScreenProbeGather.GatherNumMips', config.mips)
            setCVar('r.LumenScene.SurfaceCache.Feedback.ResLevelBias', config.feedbackres)
            setCVar('r.LumenScene.SurfaceCache.CardMaxTexelDensity', config.texeldensity)
            setCVar('r.LumenScene.SurfaceCache.AtlasSize', config.atlasres)
        end,
        mode = 'replace'
    },
    
    applyLightingResolution = {
        func = function(quality, setCVar)
            local qualityMap = {
                low = '48', medium = '32', mediumhigh = '28', high = '24',
                veryhigh = '20', epic = '16', insane = '12', extreme = '8'
            }
            
            local value = qualityMap[quality]
            if value then
                setCVar('r.Lumen.ScreenProbeGather.DownsampleFactor', value)
                setCVar('r.Lumen.ScreenProbeGather.DownsampleFactorProxy', value)
            end
        end,
        mode = 'replace'
    }
}

SilentHillOverrides.customHandler = function(key, value, SettingsManager, setCVar, setCvarOnce)
    return false
end

RegisterKeyBind(Key.F10, function()
	setCvarOnce('fov', '')
end)

-- Initialization functions
SilentHillOverrides.initFunctions = {}

local Hooks = require('hooks')
local SafeExec = require('safe_exec')
local Logger = require('logger')

-- First-person head-tracking and head-hiding state
local fppHeadInitialized = false
local fppHeadEnabled = true
local trackedCharAddr = nil
local trackedChar = nil
local trackedMesh = nil
local trackedSpringArm = nil
local trackedView = nil
local trackedPC = nil
local origParent = nil
local origDoCollisionTest = nil
local origCameraLag = nil
local origCameraRotLag = nil
local origSocketOffset = nil
local thirdPersonActive = false
local lastSyncArmAddr = nil
local lastSyncPitch = nil
local lastSyncYaw = nil
local lastSyncRoll = nil
local rotSyncTickCounter = 0

local HEAD_BONE_NAME = 'head_bn'
local NONE_NAME = 'None'
local ZERO_VEC = {X = 0.0, Y = 0.0, Z = 0.0}
local DEFAULT_VIEW_LOC = {X = 0.0, Y = 0.0, Z = 60.0}
local ZERO_ROT = {Pitch = 0.0, Yaw = 0.0, Roll = 0.0}
local ROT_TBL = {Pitch = 0.0, Yaw = 0.0, Roll = 0.0}
local EMPTY_HIT = {}

local function resetLastSyncRotation()
    lastSyncArmAddr = nil
    lastSyncPitch = nil
    lastSyncYaw = nil
    lastSyncRoll = nil
    rotSyncTickCounter = 0
end

local function clearSpringArmBackup()
    origDoCollisionTest = nil
    origCameraLag = nil
    origCameraRotLag = nil
    origSocketOffset = nil
end

local function isValidUObject(obj)
    if not obj then return false end
    local ok, valid = pcall(function()
        return obj:IsValid()
    end)
    return ok and valid == true
end

local function isNonDefaultUObject(obj)
    if not isValidUObject(obj) then return false end
    local ok, fullName = pcall(function()
        return obj:GetFullName()
    end)
    if not ok or type(fullName) ~= 'string' then
        return false
    end
    return not fullName:find('Default__', 1, true)
end

local function getObjectKey(obj)
    if not isValidUObject(obj) then return nil end
    local okAddr, addr = pcall(function()
        return obj:GetAddress()
    end)
    if okAddr and addr and addr ~= 0 then
        return tostring(addr)
    end
    local okName, fullName = pcall(function()
        return obj:GetFullName()
    end)
    if okName and fullName then
        return fullName
    end
    return nil
end

local function isSameUObject(a, b)
    if not isValidUObject(a) or not isValidUObject(b) then
        return false
    end
    local okA, addrA = pcall(function()
        return a:GetAddress()
    end)
    local okB, addrB = pcall(function()
        return b:GetAddress()
    end)
    return okA and okB and addrA ~= nil and addrB ~= nil and addrA ~= 0 and addrB ~= 0 and addrA == addrB
end

local function clearTrackedCache()
    trackedChar = nil
    trackedMesh = nil
    trackedSpringArm = nil
    trackedView = nil
    trackedPC = nil
    resetLastSyncRotation()
    clearSpringArmBackup()
end

local origSpringArmAddr = nil

local function backupSpringArmSettings(springArm)
    local armAddr = getObjectKey(springArm)
    if not armAddr then return end
    if origSpringArmAddr == armAddr and origDoCollisionTest ~= nil then
        return
    end
    origSpringArmAddr = armAddr

    pcall(function()
        origDoCollisionTest = springArm.bDoCollisionTest
        origCameraLag = springArm.bEnableCameraLag
        origCameraRotLag = springArm.bEnableCameraRotationLag
        local sock = springArm.SocketOffset
        if sock then
            origSocketOffset = {
                X = sock.X or 0.0,
                Y = sock.Y or 0.0,
                Z = sock.Z or 0.0
            }
        else
            origSocketOffset = ZERO_VEC
        end
    end)
end

local function getActivePlayerController(char)
    local pc = nil
    if isValidUObject(char) then
        pcall(function()
            if isNonDefaultUObject(char.Controller) then
                pc = char.Controller
            end
        end)
    end
    if not isValidUObject(pc) and FindFirstOf then
        local okPC, foundPC = pcall(FindFirstOf, 'PlayerController')
        if okPC and isNonDefaultUObject(foundPC) then
            pc = foundPC
        end
    end
    return pc
end

local function extractCharacterComponents(candidate)
    if not isNonDefaultUObject(candidate) then
        return nil
    end

    local mesh = nil
    pcall(function()
        if isValidUObject(candidate.Mesh) then
            mesh = candidate.Mesh
        elseif isValidUObject(candidate.CharacterMesh0) then
            mesh = candidate.CharacterMesh0
        end
    end)

    local springArm = nil
    pcall(function()
        if isValidUObject(candidate.SpringArm) then
            springArm = candidate.SpringArm
        end
    end)

    local view = nil
    pcall(function()
        if isValidUObject(candidate.View) then
            view = candidate.View
        end
    end)

    if isValidUObject(mesh) and isValidUObject(springArm) and isValidUObject(view) then
        return candidate, mesh, springArm, view
    end
    return nil
end

local function getActiveCharacterComponents()
    if not FindFirstOf then
        return nil
    end

    local okChar, foundChar = pcall(FindFirstOf, 'SHCharacterPlay_BP_C')
    if okChar then
        local char, mesh, springArm, view = extractCharacterComponents(foundChar)
        if char then
            return char, mesh, springArm, view
        end
    end

    local okPC, pc = pcall(FindFirstOf, 'PlayerController')
    if okPC and isNonDefaultUObject(pc) then
        local okPawn, pawn = pcall(function()
            return pc.Pawn
        end)
        if okPawn then
            local char, mesh, springArm, view = extractCharacterComponents(pawn)
            if char then
                return char, mesh, springArm, view
            end
        end
    end

    return nil
end

local function syncTrackedCharacter(char, mesh, springArm, view)
    local charKey = getObjectKey(char)
    if charKey and charKey ~= trackedCharAddr then
        trackedCharAddr = charKey
        origParent = nil
        thirdPersonActive = false
    end

    trackedChar = char
    trackedMesh = mesh
    trackedSpringArm = springArm
    trackedView = view
    trackedPC = getActivePlayerController(char)
end

local function setDLCSkinHidden(char, hidden)
    pcall(function()
        if isValidUObject(char.DLCSkinStaticMesh) then
            char.DLCSkinStaticMesh:SetHiddenInGame(hidden, true)
        end
    end)
end

local function getFallbackRootParent(char)
    local fallback = nil
    pcall(function()
        if isValidUObject(char.CollisionCylinder) then
            fallback = char.CollisionCylinder
        elseif isValidUObject(char.CapsuleComponent) then
            fallback = char.CapsuleComponent
        elseif isValidUObject(char.RootComponent) then
            fallback = char.RootComponent
        end
    end)
    return fallback
end

local function ensureViewUnderRoot(char, view, mesh)
    if not isValidUObject(view) then return end
    local okParent, curViewParent = pcall(function()
        return view:GetAttachParent()
    end)
    if okParent and isSameUObject(curViewParent, mesh) then
        local rootParent = getFallbackRootParent(char)
        pcall(function()
            view:SetAbsolute(false, false, false)
        end)
        if isValidUObject(rootParent) then
            pcall(function()
                view:K2_AttachToComponent(rootParent, FName(NONE_NAME), 0, 0, 0, false)
            end)
        end
        pcall(function()
            view:K2_SetRelativeLocation(DEFAULT_VIEW_LOC, false, EMPTY_HIT, true)
        end)
    end
end

local function isThirdPersonOrCutscene(char, mesh, springArm, pc)
    if Hooks.isInCinematic and Hooks.isInCinematic() then
        return true
    end

    if isValidUObject(pc) then
        local okVT, vt = pcall(function()
            return pc:GetViewTarget()
        end)
        if okVT and isValidUObject(vt) and not isSameUObject(vt, char) then
            return true
        end

        local okCamLoc, camLoc = pcall(function()
            local pcm = pc.PlayerCameraManager
            if isValidUObject(pcm) then
                return pcm:GetCameraLocation()
            end
            return nil
        end)
        local okHeadLoc, headLoc = pcall(function()
            return mesh:GetSocketLocation(FName(HEAD_BONE_NAME))
        end)
        if okCamLoc and camLoc and okHeadLoc and headLoc then
            local okDist, dx, dy, dz = pcall(function()
                return camLoc.X - headLoc.X, camLoc.Y - headLoc.Y, camLoc.Z - headLoc.Z
            end)
            if okDist and dx and dy and dz then
                local distSq = dx * dx + dy * dy + dz * dz
                if thirdPersonActive then
                    if distSq > 1600.0 then -- 40 cm hysteresis exit
                        return true
                    end
                elseif distSq > 3600.0 then -- 60 cm enter
                    return true
                end
            end
        end
    end

    local okArmLen, armLen = pcall(function()
        return springArm.TargetArmLength
    end)
    if okArmLen and type(armLen) == 'number' then
        if thirdPersonActive then
            if armLen > 20.0 then return true end
        elseif armLen > 25.0 then
            return true
        end
    end

    return false
end

local function readViewRotationIntoTbl(view)
    if not isValidUObject(view) then
        return false
    end

    local ok, rot = pcall(function()
        return view:GetViewRotation()
    end)
    local okPYR, p, y, r = false, nil, nil, nil
    if ok and rot then
        okPYR, p, y, r = pcall(function()
            return rot.Pitch, rot.Yaw, rot.Roll
        end)
    end

    if not okPYR or p == nil or y == nil or r == nil or math.abs(p) < 0.0001 then
        local okComp, compRot = pcall(function()
            return view:K2_GetComponentRotation()
        end)
        if okComp and compRot then
            local okC, cp, cy, cr = pcall(function()
                return compRot.Pitch, compRot.Yaw, compRot.Roll
            end)
            if okC and cp ~= nil and cy ~= nil and cr ~= nil then
                if not okPYR or p == nil or y == nil or r == nil then
                    p, y, r = cp, cy, cr
                    okPYR = true
                elseif math.abs(cp) >= 0.0001 then
                    p = cp
                end
            end
        end
    end

    if okPYR and p ~= nil and y ~= nil and r ~= nil then
        ROT_TBL.Pitch = p
        ROT_TBL.Yaw = y
        ROT_TBL.Roll = r
        return true
    end
    return false
end

local function runOnGameThread(fn)
    if IsInGameThread and IsInGameThread() then
        fn()
    else
        SafeExec.executeInGameThread(fn)
    end
end

local function scheduleGameThreadDelay(delayMs, fn)
    if ExecuteInGameThreadWithDelay then
        pcall(ExecuteInGameThreadWithDelay, delayMs, fn)
    else
        SafeExec.executeWithDelay(delayMs, fn)
    end
end

local function applyRotationSyncOnGameThread()
    if not fppHeadEnabled or thirdPersonActive or (Hooks.isInCinematic and Hooks.isInCinematic()) then
        return
    end

    local char = trackedChar
    local mesh = trackedMesh
    local springArm = trackedSpringArm
    local view = trackedView
    if not isValidUObject(char) or not isValidUObject(mesh) or not isValidUObject(springArm) or not isValidUObject(view) then
        clearTrackedCache()
        return
    end

    local okParent, curParent = pcall(function()
        return springArm:GetAttachParent()
    end)
    if not okParent or not isSameUObject(curParent, mesh) then
        return
    end

    if not readViewRotationIntoTbl(view) then
        return
    end

    local armAddr = getObjectKey(springArm)
    rotSyncTickCounter = rotSyncTickCounter + 1
    if armAddr and armAddr == lastSyncArmAddr and lastSyncPitch ~= nil and lastSyncYaw ~= nil and lastSyncRoll ~= nil then
        local changed = math.abs(ROT_TBL.Pitch - lastSyncPitch) > 0.002
            or math.abs(ROT_TBL.Yaw - lastSyncYaw) > 0.002
            or math.abs(ROT_TBL.Roll - lastSyncRoll) > 0.002
        if not changed and rotSyncTickCounter < 30 then
            return
        end
    end

    local okRot = pcall(function()
        springArm:K2_SetWorldRotation(ROT_TBL, false, EMPTY_HIT, true)
    end)
    if okRot then
        lastSyncArmAddr = armAddr
        lastSyncPitch = ROT_TBL.Pitch
        lastSyncYaw = ROT_TBL.Yaw
        lastSyncRoll = ROT_TBL.Roll
        rotSyncTickCounter = 0
    end
end

local function applyFPPHeadTrackingOnGameThread()
    if not fppHeadEnabled then
        return
    end

    local char, mesh, springArm, view = getActiveCharacterComponents()
    if not char then return end

    syncTrackedCharacter(char, mesh, springArm, view)
    ensureViewUnderRoot(char, view, mesh)

    if isThirdPersonOrCutscene(char, mesh, springArm, trackedPC) then
        thirdPersonActive = true
        return
    end
    thirdPersonActive = false

    backupSpringArmSettings(springArm)

    local curArmParent = nil
    pcall(function()
        curArmParent = springArm:GetAttachParent()
    end)

    if not isSameUObject(curArmParent, mesh) then
        if not isValidUObject(origParent) or isSameUObject(origParent, mesh) then
            if isValidUObject(curArmParent) and not isSameUObject(curArmParent, mesh) then
                origParent = curArmParent
            else
                origParent = view
            end
        end

        pcall(function()
            springArm:K2_AttachToComponent(mesh, FName(HEAD_BONE_NAME), 2, 1, 1, false)
            springArm:K2_SetRelativeLocation(ZERO_VEC, false, EMPTY_HIT, true)
        end)
    end

    pcall(function()
        springArm:SetAbsolute(false, true, true)
        springArm.bUsePawnControlRotation = false
        springArm.bDoCollisionTest = false
        springArm.bEnableCameraLag = false
        springArm.bEnableCameraRotationLag = false
        springArm.SocketOffset = ZERO_VEC
    end)
    pcall(function()
        mesh:HideBoneByName(FName(HEAD_BONE_NAME), 0)
    end)
    setDLCSkinHidden(char, true)

    resetLastSyncRotation()
    applyRotationSyncOnGameThread()
end

local function applyFPPHeadTracking()
    if not fppHeadEnabled or (Hooks.isInCinematic and Hooks.isInCinematic()) then
        return
    end
    runOnGameThread(applyFPPHeadTrackingOnGameThread)
end

local function restoreFPPHeadTrackingOnGameThread()
    local char, mesh, springArm, view = getActiveCharacterComponents()
    if not char then
        if isValidUObject(trackedChar) and isValidUObject(trackedMesh) and isValidUObject(trackedSpringArm) and isValidUObject(trackedView) then
            char, mesh, springArm, view = trackedChar, trackedMesh, trackedSpringArm, trackedView
        else
            return
        end
    end

    syncTrackedCharacter(char, mesh, springArm, view)
    ensureViewUnderRoot(char, view, mesh)

    local armAddr = getObjectKey(springArm)
    pcall(function()
        springArm.bUsePawnControlRotation = false
        springArm:SetAbsolute(false, false, false)
        if armAddr and armAddr == origSpringArmAddr then
            if origDoCollisionTest ~= nil then
                springArm.bDoCollisionTest = origDoCollisionTest
            end
            if origCameraLag ~= nil then
                springArm.bEnableCameraLag = origCameraLag
            end
            if origCameraRotLag ~= nil then
                springArm.bEnableCameraRotationLag = origCameraRotLag
            end
            if origSocketOffset ~= nil then
                springArm.SocketOffset = origSocketOffset
            end
        end
    end)

    local targetParent = nil
    if isValidUObject(view) and not isSameUObject(view, mesh) then
        targetParent = view
    elseif isValidUObject(origParent) and not isSameUObject(origParent, mesh) then
        targetParent = origParent
    else
        targetParent = getFallbackRootParent(char)
    end

    if isValidUObject(targetParent) then
        pcall(function()
            springArm:K2_AttachToComponent(targetParent, FName(NONE_NAME), 0, 0, 0, false)
        end)
    end

    pcall(function()
        springArm:K2_SetRelativeLocation(ZERO_VEC, false, EMPTY_HIT, true)
    end)
    pcall(function()
        springArm:K2_SetRelativeRotation(ZERO_ROT, false, EMPTY_HIT, true)
    end)

    pcall(function()
        mesh:UnHideBoneByName(FName(HEAD_BONE_NAME))
    end)
    setDLCSkinHidden(char, false)
    resetLastSyncRotation()
end

local function maintainFPPHeadTrackingOnGameThread()
    if not fppHeadEnabled then
        return
    end

    local char, mesh, springArm, view = getActiveCharacterComponents()
    if not char then
        clearTrackedCache()
        return
    end

    syncTrackedCharacter(char, mesh, springArm, view)

    if isThirdPersonOrCutscene(char, mesh, springArm, trackedPC) then
        if not thirdPersonActive then
            thirdPersonActive = true
            restoreFPPHeadTrackingOnGameThread()
        else
            pcall(function()
                mesh:UnHideBoneByName(FName(HEAD_BONE_NAME))
            end)
            setDLCSkinHidden(char, false)
        end
        return
    end

    if thirdPersonActive then
        thirdPersonActive = false
        applyFPPHeadTrackingOnGameThread()
        return
    end

    local needsReapply = false
    local okHidden, isHidden = pcall(function()
        return mesh:IsBoneHiddenByName(FName(HEAD_BONE_NAME))
    end)
    if okHidden and not isHidden then
        needsReapply = true
    end

    if not needsReapply then
        local okParent, curArmParent = pcall(function()
            return springArm:GetAttachParent()
        end)
        if okParent and not isSameUObject(curArmParent, mesh) then
            needsReapply = true
        end
    end

    if not needsReapply then
        local okFlags, absRot, usePawnCtrl, doCol, camLag, rotLag = pcall(function()
            return springArm.bAbsoluteRotation,
                springArm.bUsePawnControlRotation,
                springArm.bDoCollisionTest,
                springArm.bEnableCameraLag,
                springArm.bEnableCameraRotationLag
        end)
        if okFlags and (absRot == false or usePawnCtrl == true or doCol == true or camLag == true or rotLag == true) then
            needsReapply = true
        end
    end

    if needsReapply then
        applyFPPHeadTrackingOnGameThread()
    end
end

local function restoreFPPHeadTracking()
    runOnGameThread(restoreFPPHeadTrackingOnGameThread)
end

table.insert(SilentHillOverrides.initFunctions, function(configPath, setCVar, settingsManager)
    if fppHeadInitialized then
        applyFPPHeadTracking()
        return
    end
    fppHeadInitialized = true

    local existingCinematicCallback = Hooks.getCinematicCallback and Hooks.getCinematicCallback()
    if Hooks.setCinematicCallback then
        Hooks.setCinematicCallback(function(isCinematic)
            if existingCinematicCallback then
                pcall(existingCinematicCallback, isCinematic)
            end
            if isCinematic then
                restoreFPPHeadTracking()
            else
                applyFPPHeadTracking()
                -- Re-apply after 500ms so post-cutscene camera resets do not undo head attachment
                scheduleGameThreadDelay(500, function()
                    if fppHeadEnabled and not (Hooks.isInCinematic and Hooks.isInCinematic()) then
                        applyFPPHeadTrackingOnGameThread()
                    end
                end)
            end
        end)
    end

    if RegisterKeyBind and Key and Key.F11 then
        pcall(RegisterKeyBind, Key.F11, function()
            fppHeadEnabled = not fppHeadEnabled
            if fppHeadEnabled then
                Logger.info('FPP head tracking enabled (F11)')
                applyFPPHeadTracking()
            else
                Logger.info('FPP head tracking disabled (F11)')
                restoreFPPHeadTracking()
            end
        end)
    else
        Logger.warn('RegisterKeyBind or Key.F11 unavailable; FPP head toggle keybind skipped')
    end

    scheduleGameThreadDelay(1500, applyFPPHeadTrackingOnGameThread)

    local function runMaintenanceStep()
        if not fppHeadEnabled then
            return false
        end
        local ok, err = pcall(maintainFPPHeadTrackingOnGameThread)
        if not ok then
            Logger.debug('FPP maintenance error: %s', tostring(err))
        end
        return false
    end

    local function runRotationSyncStep()
        if not fppHeadEnabled or thirdPersonActive or (Hooks.isInCinematic and Hooks.isInCinematic()) then
            return false
        end
        if not trackedSpringArm then
            return false
        end
        local ok, err = pcall(applyRotationSyncOnGameThread)
        if not ok then
            Logger.debug('FPP rotation sync error: %s', tostring(err))
        end
        return false
    end

    -- Execute both loops directly inside UE4SS EngineTick (GameThread) to avoid LoopAsync lua_State races
    if LoopInGameThreadWithDelay then
        LoopInGameThreadWithDelay(150, runMaintenanceStep)
        LoopInGameThreadWithDelay(1, runRotationSyncStep)
    else
        SafeExec.loopAsync(150, function()
            SafeExec.executeInGameThread(runMaintenanceStep)
            return false
        end)
        SafeExec.loopAsync(16, function()
            SafeExec.executeInGameThread(runRotationSyncStep)
            return false
        end)
    end
end)

SilentHillOverrides.earlyInit = false
SilentHillOverrides.initDelay = 1000

SilentHillOverrides.generatePresets = true
SilentHillOverrides.rtAllowed = true

SilentHillOverrides.criticalSettings = {'FogDOF', 'FOV'}
SilentHillOverrides.restartCriticalSettings = {'FogDOF', 'FOV', 'LightingMode'}

SilentHillOverrides.ppvNotifyDelay = 2

return SilentHillOverrides
