IncludeFile("Lib\\TOIR_SDK.lua")

XinZhao = class()

function OnLoad()
	if GetChampName(GetMyChamp()) == "XinZhao" then
		XinZhao:__init()
	end
end

function XinZhao:__init()

    self.menu_ts = TargetSelector(900, 0, myHero, true, true, true)
    vpred = VPrediction(true)

    self:XinZhaoMenu()

    self.Q = Spell(_Q, GetTrueAttackRange())
    self.W = Spell(_W, 600)
    self.E = Spell(_E, 650)
    self.R = Spell(_R, 250)

    self.Q:SetActive()
    self.W:SetSkillShot(0.50, 600, 180, false)
    self.E:SetTargetted()
    self.R:SetActive()


    Callback.Add("Tick", function(...) self:OnTick(...) end)
	Callback.Add("DrawMenu", function(...) self:OnDrawMenu(...) end)
	Callback.Add("Draw", function(...) self:OnDraw(...) end)
end

function XinZhao:XinZhaoMenu()
	self.menu = "XinZhao" 
	self.Use_Combo_Q = self:MenuBool("Use Combo Q", true)
	self.Use_Combo_W = self:MenuBool("Use Combo W", true)
	self.Use_Combo_E = self:MenuBool("Use Combo E", true)
	self.Use_Combo_R = self:MenuBool("Use Combo R", true)

	self.R_Auto = self:MenuBool("Auto R", true)
    self.R_enemyCount = self:MenuSliderInt("R when X enimies",2)
    self.R_LowHP = self:MenuSliderInt("R Low HP%",20)

    self.Use_Jung_Q = self:MenuBool("Use Combo Q", true)
    self.Use_Jung_W = self:MenuBool("Use Combo W", true)
	self.Use_Jung_E = self:MenuBool("Use Combo E", true)
	self.JMana = self:MenuSliderInt("Jungle Mana%", 30)

	self.Combo = self:MenuKeyBinding("Combo", 32)
	self.Harass = self:MenuKeyBinding("Harass", 67)
	self.Lane_Clear = self:MenuKeyBinding("Lane Clear", 86)
	self.Last_Hit = self:MenuKeyBinding("Last Hit", 88)
	self.Flee = self:MenuKeyBinding("Flee", 65)
end

function XinZhao:OnDrawMenu()
	if Menu_Begin(self.menu) then
		if Menu_Begin("XinZhao Config [Q]") then
			self.Use_Combo_Q = Menu_Bool("Use Combo Q", self.Use_Combo_Q, self.menu)
			Menu_End()
		end
		if Menu_Begin("XinZhao Config [W]") then
			self.Use_Combo_W = Menu_Bool("Use Combo W", self.Use_Combo_W, self.menu)
			Menu_End()
		end
		if Menu_Begin("XinZhao Config [E]") then
            self.Use_Combo_E = Menu_Bool("Use Combo E", self.Use_Combo_E, self.menu)
			Menu_End()
		end

		if Menu_Begin("XinZhao Config [R]") then
            self.Use_Combo_R = Menu_Bool("Use Combo R", self.Use_Combo_R, self.menu)
            self.R_Auto = Menu_Bool("Auto R", self.R_Auto, self.menu)
            self.R_enemyCount = Menu_SliderInt("R when X enimies", self.R_enemyCount, 2, 5, self.menu)
            self.R_LowHP = Menu_SliderInt("R Low HP%", self.R_LowHP, 5, 100, self.menu)
			Menu_End()
		end

		if Menu_Begin("XinZhao Jungle") then
            self.Use_Jung_Q = Menu_Bool("Use Q", self.Use_Jung_Q, self.menu)
            self.Use_Jung_W = Menu_Bool("Use W", self.Use_Jung_W, self.menu)
            self.Use_Jung_E = Menu_Bool("Use E", self.Use_Jung_E, self.menu)
			self.JMana = Menu_SliderInt("Mana %", self.JMana, 0, 100, self.menu)
			Menu_End()
		end

		if Menu_Begin("Keys") then
			self.Combo = Menu_KeyBinding("Combo", self.Combo, self.menu)
			self.Harass = Menu_KeyBinding("Harass", self.Harass, self.menu)
			self.Lane_Clear = Menu_KeyBinding("Lane Clear", self.Lane_Clear, self.menu)
			self.Last_Hit = Menu_KeyBinding("Last Hit", self.Last_Hit, self.menu)
			self.Flee = Menu_KeyBinding("Flee", self.Flee, self.menu)
			Menu_End()
		end
		Menu_End()
	end
end


function XinZhao:OnTick()
	if IsDead(myHero.Addr) or IsTyping() or IsDodging() or myHero.IsRecall then return end
	SetLuaCombo(true)

	if self.R:IsReady() and self.R_Auto and (CountEnemyChampAroundObject(myHero.Addr, self.R.range) >= self.R_enemyCount or (GetPercentHP(myHero.Addr) <= self.R_LowHP and GetTargetSelector(self.R.range) ~= 0))  then
		CastSpellTarget(myHero.Addr, _R)
	end

	if GetKeyPress(self.Lane_Clear) > 0 then
        self:JungClear()
	end

    if GetKeyPress(self.Combo) > 0 then
        local target = self.menu_ts:GetTarget()
        if target ~= 0 then
        self:CastQ(target)
        self:CastW(target)
		self:CastE(target)
		self:CastR()
        end
    end
end

function XinZhao:JungClear()
	tmon = GetUnit(GetTargetOrb())
    if tmon ~= 0 and GetPercentMP(myHero.Addr) >= self.JMana and (GetType(GetTargetOrb()) == 3)  and (GetObjName(GetTargetOrb()) ~= ("PlantSatchel" or "PlantHealth" or "PlantVision")) then
		if self.Use_Jung_Q and CanCast(_Q) and GetDistance(tmon) < self.Q.range then CastSpellTarget(myHero.Addr, _Q) end
		if self.Use_Jung_E and CanCast(_E) and GetDistance(tmon) < self.E.range then CastSpellTarget(tmon.Addr, _E) end
		if self.Use_Jung_W and CanCast(_W) and GetDistance(tmon) < self.W.range then CastSpellToPos(tmon.x, tmon.z, _W) end
    end
end

function XinZhao:MenuBool(stringKey, bool)
	return ReadIniBoolean(self.menu, stringKey, bool)
end

function XinZhao:MenuSliderInt(stringKey, valueDefault)
	return ReadIniInteger(self.menu, stringKey, valueDefault)
end

function XinZhao:MenuKeyBinding(stringKey, valueDefault)
	return ReadIniInteger(self.menu, stringKey, valueDefault)
end


  
function XinZhao:CastQ(target)
    if self.Q:IsReady() and IsValidTarget(target, self.Q.range) and self.Use_Combo_Q  then
        CastSpellTarget(myHero.Addr, _Q)
    end
end


function XinZhao:CastE(target)
    if self.E:IsReady() and IsValidTarget(target, self.E.range) and self.Use_Combo_E then
        CastSpellTarget(target, _E)
    end
end

function XinZhao:CastR(target)
    if self.R:IsReady() and self.Use_Combo_R and CountEnemyChampAroundObject(myHero, self.R.range) >= self.R_enemyCount then
        CastSpellTarget(myHero.Addr, _R)
    end
end

function XinZhao:CastW(target)
        if self.W:IsReady() and IsValidTarget(target, self.W.range) and CanCast(_W) then
            targetW = GetAIHero(target)
            local CastPosition, HitChance, Position = vpred:GetLineCastPosition(targetW, self.W.delay, self.W.width, self.W.range, self.W.speed, myHero, false)
            if HitChance >= 2 then
            CastSpellToPos(CastPosition.x, CastPosition.z, _W)
        end
    end  
end 

function XinZhao:OnDraw()
        DrawCircleGame(myHero.x, myHero.y, myHero.z,self.E.range, Lua_ARGB(255,255,0,0))
end 