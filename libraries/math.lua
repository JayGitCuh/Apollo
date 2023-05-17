local dwRunservice = game:GetService("RunService");
local dwPlayers = game:GetService('Players');
local dwLocalPlayer = dwPlayers.LocalPlayer;
local dwMouse = dwLocalPlayer:GetMouse();
local dwWorkspace = game:GetService("Workspace");
local dwCamera = dwWorkspace.CurrentCamera;
local dwUserInputService = game:GetService("UserInputService");
local Vector3_new = Vector3.new
local Vector2_new = Vector2.new
local math_tan = math.tan
local math_rad = math.rad
local Ray_new = Ray.new
local Px
local Py
local Pz
local sx
local sy
local d
local px, py, pz
local cx, cy, cz, rx, ux, bx, ry, uy, by, rz, uz, bz
local x_scale
local y_scale
local vx, vy
local v
local cframe
local on_screen
local maths = {}
function maths.DecRound(x)
	return x>=0 and math.floor(x+0.5) or math.ceil(x-0.5)
end
function maths.NumToPercent(CurNum, MaxNum, round, raw) -- by duck
	local temp = (CurNum / MaxNum) * 1000
	if not raw and round then
	return maths.DecRound(temp) / 10
	elseif raw and not round then
	return (CurNum / MaxNum)
	elseif raw and round then
	return error("Don't Enable Raw and Round")
	else
	return "ENABLE RAW OR ROUND"
	end
end
function maths.WorldToScreen(pos)
	cframe = dwCamera.CFrame
	v = dwCamera.ViewportSize
	vx, vy = v.X, v.Y
	y_scale = math_tan(math_rad(dwCamera.FieldOfView/2))
	x_scale = y_scale*vx/vy
	cx, cy, cz, rx, ux, bx, ry, uy, by, rz, uz, bz = cframe:GetComponents()
	px, py, pz = pos.X, pos.Y, pos.Z
	d = -bz*ry*ux + by*rz*ux + bz*rx*uy - bx*rz*uy - by*rx*uz + bx*ry*uz
	if d == 0 then
		return
	end
	Px = (-((cz - pz)*(by*ux - bx*uy)) + bz*(cy*ux - py*ux - cx*uy + px*uy) + by*(cx - px)*uz + bx*(-cy + py)*uz)/d
	Py = ((cz - pz)*(by*rx - bx*ry) + bz*(-cy*rx + py*rx + cx*ry - px*ry) + by*(-cx + px)*rz + bx*(cy - py)*rz)/d
	Pz = (cz*ry*ux - pz*ry*ux - cy*rz*ux + py*rz*ux - cz*rx*uy + pz*rx*uy + cx*rz*uy - px*rz*uy + (cy*rx - py*rx + (-cx + px)*ry)*uz)/d
	sx = vx*(0.5 + Px/(2*-Pz*x_scale))
	sy = vy*(0.5 - Py/(2*-Pz*y_scale))
	on_screen = -Pz > 0 and sx >= 0 and sx <= vx and sy >= 0 and sy <= vy
	return Vector3_new(sx, sy, -Pz), on_screen
end
function maths.Ray_New(x: Vector3, y: Vector3)
	return Ray_new(x,(y - x).Unit * 9e9)
end
function maths.Vec2Udim(Vec)
	return UDim2.new(0,Vec.X,0,Vec.Y)
end
function maths.GetBoundingBox(Model)
	local vTop
	local vBottom
	if Model:FindFirstChild('Torso') ~= nil then
		vTop = Model.Torso.Position + (Model.Torso.CFrame.UpVector * 1.7) + dwCamera.CFrame.UpVector
		vBottom = Model.Torso.Position - (Model.Torso.CFrame.UpVector * 2.5) - dwCamera.CFrame.UpVector
	elseif Model:FindFirstChild('UpperTorso') ~= nil then
		if game.PlaceId == 2555870920 then
			vTop = Model.UpperTorso.Position + (Model.UpperTorso.CFrame.UpVector * 10) + dwCamera.CFrame.UpVector
			vBottom = Model.UpperTorso.Position - (Model.UpperTorso.CFrame.UpVector * 12) - dwCamera.CFrame.UpVector
		else
			vTop = Model.UpperTorso.Position + (Model.UpperTorso.CFrame.UpVector * 1.8) + dwCamera.CFrame.UpVector
			vBottom = Model.UpperTorso.Position - (Model.UpperTorso.CFrame.UpVector * 2.5) - dwCamera.CFrame.UpVector
		end
	elseif Model.PrimaryPart ~= nil then
		vTop = Model.PrimaryPart.Position + (Model.PrimaryPart.CFrame.UpVector * 1.8) + dwCamera.CFrame.UpVector
		vBottom = Model.PrimaryPart.Position - (Model.PrimaryPart.CFrame.UpVector * 2.5) - dwCamera.CFrame.UpVector
	end
	local top, topIsRendered = dwCamera:WorldToViewportPoint(vTop)
	local bottom, bottomIsRendered = dwCamera:WorldToViewportPoint(vBottom)
	local _width = math.max(math.floor(math.abs(top.X - bottom.X)), 3)
	local _height = math.max(math.floor(math.max(math.abs(bottom.Y - top.Y), _width / 2)), 3)
	local boxSize = Vector2.new(math.floor(math.max(_height / 1.5, _width)), _height)
	local boxPosition = Vector2.new(math.floor(top.X * 0.5 + bottom.X * 0.5 - boxSize.X * 0.5), math.floor(math.min(top.Y, bottom.Y)))
	return boxPosition, boxSize, topIsRendered, bottomIsRendered
end
function maths.Vec3_Vec2(Vec)
	return Vector2_new(Vec.X, Vec.Y)
end
function maths.GetDistance(one)
	return (one - Vector2_new(dwCamera.CFrame.Position.X, dwCamera.CFrame.Position.Y)).Magnitude
end
local function lerp(start_value, end_value, t)
    return start_value * (1-math.clamp(t, 0, 1)) + end_value * t
end
maths.lerp = lerp
function maths.lerp_vector3(start_position, end_position, t)
    t = math.clamp(t, 0, 1)
    local x = lerp(start_position.X, end_position.X, t)
    local y = lerp(start_position.Y, end_position.Y, t)
    local z = lerp(start_position.Z, end_position.Z, t)
    return Vector3.new(x, y, z)
end
local r,g,b
function maths.lerp_color3(start_color, end_color, t)
    t = math.clamp(t, 0, 1)
    r = lerp(start_color.R, end_color.R, t)
    g = lerp(start_color.G, end_color.G, t)
    b = lerp(start_color.B, end_color.B, t)
    return Color3.fromRGB(r * 255, g * 255, b * 255)
end
function maths.fade(object, target_transparency, duration)
    local start_transparency = object.Transparency
    local current_time = 0
    while current_time < duration do
        local delta_time = task.wait()
        current_time = current_time + delta_time
        local t = current_time / duration
        object.Transparency = lerp(start_transparency, target_transparency, t)
    end
    object.Transparency = target_transparency
end
function maths.move(object, target_position, duration)
    local start_position = object.Position
    local current_time = 0
    while current_time < duration do
        local delta_time = task.wait()
        current_time = current_time + delta_time
        local t = current_time / duration
        object.Position = maths.lerp_vector3(start_position, target_position, t)
    end
    object.Position = target_position
end
function maths.change_color(object, target_color, duration)
    local start_color = object.Color
    local current_time = os.clock()
    while current_time < duration do
        local delta_time = os.clock() - current_time
        current_time = current_time + delta_time
        local t = current_time / duration
        object.Color = maths.lerp_color3(start_color, target_color, t)
    end
    object.Color = target_color
end
--Corners from v3 server
do
	function maths.Corners(Model)
		return setmetatable({}, {
			__index = function(self, ind)
				local pos, size = maths.GetBoundingBox(Model:GetChildren())
				local size_2 = size/2
				local corners = table.create(8)
				for i = 0, 7 do
					corners[i + 1] = pos * (Vector3.new(bit32.extract(i, 1)*2 - 1, bit32.extract(i, 0)*2 - 1, bit32.extract(i, 2)*2 - 1)*size_2)
				end
				return corners[ind]
			end
		})
	end
end
return maths;
