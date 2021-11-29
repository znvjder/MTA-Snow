--[[
    @author: l0nger <l0nger.programmer@gmail.com>
    @date created: 29.11.2021
    @version: 1.0.0

    All rights reserved. (C) 2021 JKK.
]]

local sw,sh = guiGetScreenSize()
local rawShader = [[
float3 cam_position = float3(0, 0, 0);
float3 cam_rotation = float3(0, 0, 0);
float3 cam_velocity = float3(0, 0, 0);
    
float alpha = 0;
float sensivity = 8;
    
float gTime : TIME;
    
float2 resolution = float2(1600, 900);
float2 middle = float2(0.5, 0.5);
float kx12[6] = {
    12 * 1,12 * 2,
    12 * 3,12 * 4,
    12 * 5,12 * 6
};
float4 gradient_color = float4(0.5, 0.8, 1.0, 0.0);
float2 val_stat = float2(32.4691, 94.615);
float2 static_random = float2(12.9898, 78.233);
    
float4 renderSnow(float4 fragCoord : VPOS) : COLOR {
    float snow = 0.0;   
    fragCoord.y = 1 - fragCoord.y;
    
    float gradient = (1.0 - float(fragCoord.y / resolution.x)) * 0.6;
    
    fragCoord.x = fragCoord.x + cam_rotation.z * sensivity;
    fragCoord.y = fragCoord.y - cam_rotation.x * sensivity;
    
    float random = frac(sin(dot(fragCoord.xy, static_random)) * 43758.5453); 
    float iTime = gTime + length(cam_velocity) * 10;
    
    float magnitude_mul = iTime * 2.5;
    for (int k = 0; k < 1; k++) {
        float k6185 = k * 6185;
        float k1352 = k * 1352;
        float k315 = k * 315.156;
        float k9495 = 94.674 + k * 95.0;
        float k6223 = 62.2364 + k * 23.0;
        for (int i = 0; i < 12; i++) {
            float cellSize = 2.2 + i * 3.0;
            float downSpeed = 0.32453 + (sin(iTime * 0.4 + k + i * 20) + 1.0) * 0.00008;
            float2 uv = (fragCoord.xy / resolution.x) + float2(0.01 * sin( (iTime + k6185) * 0.6 + i) * ( 5.0 / i ), downSpeed * ( iTime + k1352 ) * ( 1.0 / i ) );
            float2 uvStep = (ceil(uv * cellSize - middle) / cellSize);
     
            float x = frac(sin(dot(uvStep.xy, float2(12.9898 + kx12[k], 78.233 + k315)))* 43758.5453 + kx12[k]) - 0.5;
            float y = frac(sin(dot(uvStep.xy, float2(k6223, k9495))) * 62159.8432 + kx12[k]) - 0.5 ;
    
            float randomMagnitude1 = sin(magnitude_mul) * 0.7 / cellSize;
            float randomMagnitude2 = cos(magnitude_mul) * 0.7 / cellSize;
    
            float d = 4.0 * distance((uvStep.xy + float2(x * sin(y), y) * randomMagnitude1 + float2(y, x) * randomMagnitude2), uv.xy);

            float diff = frac(sin(dot(uvStep.xy, val_stat)) * 31572.1684);
    
            if (diff < 0.09) {
                float newd = (x + 1.0) * 0.4 * clamp(1.9 - d * (15.0 + (x * 6.3)) * (cellSize / 1.4), 0.0, 1.0);
                snow += newd;
           }
        }
    }
    
    return float4(1, 1, 1, alpha) * snow + gradient * gradient_color + random * 0.01;
}
    
technique fx_snow_shader {
    pass P0 {
        PixelShader = compile ps_3_0 renderSnow();
    }
}
]]

local camHandler = false
local fxHandler = false
local fxAlpha = 0
local cx, cy, cz = 0, 0, 0

local function renderSnow()
    local mx, my, mz = getCameraMatrix()
    local mrx, mry, mrz = getElementRotation(camHandler)
    local vx, vy, vz = getElementVelocity(getPedOccupiedVehicle(localPlayer) or localPlayer)

    cx, cy, cz = cx + math.abs(vx / 10), cy + math.abs(vy / 10), cz + math.abs(vz / 10)
    dxSetShaderValue(fxHandler, "cam_rotation", mrx, mry, mrz)
    dxSetShaderValue(fxHandler, "cam_velocity", cx, cy, 0)

    local check = isLineOfSightClear(mx, my, mz - 0.3, mx, my, mz + 20) and getElementInterior(localPlayer) == 0

    fxAlpha = math.min(255, math.max(0, check and fxAlpha + 10 or fxAlpha - 10))
    dxSetShaderValue(fxHandler, "alpha", fxAlpha / 255)
    if fxAlpha > 0 then 
        dxDrawImage(0, 0, sw, sh, fxHandler)
    end
end 

function createSnow()
    if fxHandler then 
        destroySnow() 
    end 

    fxHandler = dxCreateShader(rawShader)
    if isElement(fxHandler) then 
        addEventHandler("onClientHUDRender", root, renderSnow, false, "high+100000")
        dxSetShaderValue(fxHandler, "resolution", sw, sh)
    end 
end 

function destroySnow()
    removeEventHandler("onClientHUDRender", root, renderSnow)
    if isElement(fxHandler) then 
        destroyElement(fxHandler)
        fxHandler = nil -- prevent memory leak
    end 
end 

addEventHandler("onClientResourceStart", resourceRoot, function()
    camHandler = getCamera()
    createSnow()
end)

--[[addCommandHandler("snow1", function()
    createSnow()
end)

addCommandHandler("dsnow1", function()
    destroySnow()
end)]]
