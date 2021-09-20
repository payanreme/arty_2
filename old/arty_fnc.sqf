/*
--<Nobody´s VTool>--
V 0.2021-01-31-1133
arty
*/

// Vtool Arty
// in der vtool_init_global vorhandene Arty klassen eintragen v_arty_array = ["O_Mortar_01_F","xxx"];
v_arty = {
	// [side,target side,arty array nr ,artyposmarker,TargetMarker,radius(>35),aufgabe(HE,SMOKE,FLARE,ALL),INtel(0-4, 0 ist immer, 4 ist erst bei sichtkontakt),optional spotterposmakrer, spotter arraynr] spawn v_arty;
	// [east,west,0,"mortar","target_area","HE",50,3.9,"spotter",0]spawn v_arty;
//preload
	params ["_side","_targetside","_artnr","_artypos","_tgtarea","_ammotyp","_radius","_intel","_spottpos","_spottarynr"];
	private ["_skill","_artytype","_arty","_artytgt","_artytgtary","_tgtary","_position","_tgtary","_spot","_visibility","_spottyp","_tgtsearch"];
//calculate
	_artypos = getmarkerpos _artypos;
	if (!isnil "v_vtool_skill") then {
		_skill = v_vtool_skill;} else {
		_skill = 0.8;
	};
	_artytype = v_arty_array select _artnr;

//crate arty
	_arty = [ _artypos, (random 360), _artytype, _side] call bis_fnc_spawnvehicle;
	_arty = _arty select 0;

//create spotter
	if (!isnil "_spottpos") then {
		_spottpos = getmarkerpos _spottpos;
		_spottyp = vtool_unitarray select _spottarynr;
		_spottyp = _spottyp select 1 select 0;
		_spot = [ _spottpos, _spottpos getdir getmarkerpos _tgtarea, _spottyp, _side] call bis_fnc_spawnvehicle;
		_spot = _spot select 0;
		{
			_spot disableAI _x;
		} foreach ["AUTOCOMBAT","FSM","COVER","PATH","WEAPONAIM","TEAMSWITCH"];
		_spot setCombatBehaviour "CARELESS";
		_spot addWeapon "Binocular";
		_spot selectWeapon "Binocular";
	};
	
//shooting
	sleep 3;
	while {canfire _arty} do {
//find target
		_artytgt = nil;
		_artytgtary = [];
		if (!isnil "_spottpos") then {
			{
				_tgtary = nil;
				_position = position _x; 
				_tgtary = [_tgtarea, _position] call BIS_fnc_inTrigger;			
				if (_tgtary) then {
					_visibility = [objNull,"VIEW"]checkVisibility [eyePos _spot,eyePos _x];
					if (_visibility > 0.1) then {_artytgtary = _artytgtary + [_x]};
				};
			} forEach allUnits;
		} else {
			{
				_tgtary = nil;
				_position = position _x; 
				_tgtary = [_tgtarea, _position] call BIS_fnc_inTrigger;			
				if (_tgtary) then {
					if (side _x == _targetside) then {
						if (_side knowsAbout _x > _intel) then {
							_artytgtary = _artytgtary + [_x];
						};
					};
				};
			} forEach allUnits;
		};
		if (count _artytgtary > 0) then {
			_tgtsearch = true;
			while {_tgtsearch} do {
				_artytgt = _artytgtary call BIS_fnc_selectRandom;
				if (_artytgt distance _arty > 90) then {_tgtsearch = false};
				sleep 0.5;
			};
			
			_artytgt = _artytgtary call BIS_fnc_selectRandom;
			systemchat format ["V_Tool_Arty: TgtArray: %1, Target:%2, Arty:%3, Ammo:%4",_artytgtary,_artytgt,_arty,_ammotyp];
			diag_log format ["V_Tool_Arty: TgtArray: %1, Target:%2, Arty:%3, Ammo:%4",_artytgtary,_artytgt,_arty,_ammotyp];
// call shoot
			[_ammotyp,_arty,_artytgt,_artnr,_radius] spawn v_arty_tgt;
			sleep 60;
			sleep (random 120);
		};
		sleep 15;		
	};
};

// Mun arty fnc
v_arty_tgt = {
	params ["_ammotyp","_arty","_artytgt","_artnr","_tgtradius"];
	private ["_mun","_rounds","_reload"];
	//if change on arty array - change mun here
	if (_artnr == 0) then {
		switch (_ammotyp) do {
			case "HE": {_mun = 0;_rounds = 2;_reload = 10;[_arty,_artytgt,_tgtradius,_mun,_rounds,_reload] spawn v_arty_fire;};
			case "SMOKE": {_mun = 2;_rounds = 2;_reload = 10;[_arty,_artytgt,_tgtradius,_mun,_rounds,_reload] spawn v_arty_fire;};
			case "FLARE": {_mun = 1;_rounds = 3;_reload = 60;[_arty,_artytgt,_tgtradius,_mun,_rounds,_reload] spawn v_arty_fire;};
			case "ALL": {
				_mun = 1;//flare
				_rounds = 1;
				_reload = 10;
				[_arty,_artytgt,_tgtradius,_mun,_rounds,_reload] spawn v_arty_fire;
				sleep 12;
				_mun = 0;//HE
				_rounds = 3;
				_reload = 5;
				[_arty,_artytgt,_tgtradius,_mun,_rounds,_reload] spawn v_arty_fire;
				sleep 18;
				_mun = 2;//smoke
				_rounds = 2;
				_reload = 5;
				[_arty,_artytgt,_tgtradius,_mun,_rounds,_reload] spawn v_arty_fire;
				sleep 11;
				_mun = 1;//flare
				_rounds = 3;
				_reload = 60;
				[_arty,_artytgt,_tgtradius,_mun,_rounds,_reload] spawn v_arty_fire;
			};
		};
	}else {
		if (_artnr == 1) then {
			switch (_ammotyp) do {
				case "HE": {_mun = 0;_rounds = 2;_reload = 12;[_arty,_artytgt,_tgtradius,_mun,_rounds,_reload] spawn v_arty_fire;};
				case "SMOKE": {_mun = 1;_rounds = 2;_reload = 10;[_arty,_artytgt,_tgtradius,_mun,_rounds,_reload] spawn v_arty_fire;};
				case "FLARE": {_mun = 2;_rounds = 3;_reload = 60;[_arty,_artytgt,_tgtradius,_mun,_rounds,_reload] spawn v_arty_fire;};
				case "ALL": {
					_mun = 2;//flare
					_rounds = 1;
					_reload = 3;
					[_arty,_artytgt,_tgtradius,_mun,_rounds,_reload] spawn v_arty_fire;
					sleep 8;
					_mun = 0;//HE
					_rounds = 3;
					_reload = 9;
					[_arty,_artytgt,_tgtradius,_mun,_rounds,_reload] spawn v_arty_fire;
					sleep 30;
					_mun = 1;//smoke
					_rounds = 2;
					_reload = 9;
					[_arty,_artytgt,_tgtradius,_mun,_rounds,_reload] spawn v_arty_fire;
					sleep 20;
					_mun = 2;//flare
					_rounds = 3;
					_reload = 60;
					[_arty,_artytgt,_tgtradius,_mun,_rounds,_reload] spawn v_arty_fire;
				};
			};
		};
	};
};
	
// shoot arty fnc
v_arty_fire = {
	//grundgerüst by 2nd ranger
	// [mortar,target obj,incoming radius,munition typ(0=HE,1=light,2=smoke),rounds,reloadtime] spawn v_arty_fire;
	//[mk2,target_3,10,0,3,5] spawn v_arty_fire;
	params ["_mortar","_target","_radius","_ammotyp","_rounds","_reloadtime"];
	private ["_artyammo","_targetpos"];
	_target = getpos _target;
	_artyammo = getArtilleryAmmo [_mortar] select _ammotyp;
	for "_i" from 1 to _rounds do {
		_tgtcheck = true;
		while {_tgtcheck} do {
			_targetpos = [
				(_target select 0) - _radius + (2 * random _radius),
				(_target select 1) - _radius + (2 * random _radius),
				0
			];
			_tgtcheck = false;
			_tgt = [];
			_tgt = _targetpos nearEntities ["Land", 50];
			{
			if ((_tgt findif {_x in playableunits}) > -1) then {_tgtcheck = true}; 
			} forEach _tgt;
			sleep 0.5;
		};
		if (_mortar ammo _artyammo < 2) then {
			_mortar addMagazineGlobal _artyammo;
		};
		_mortar commandArtilleryFire [ _targetpos, _artyammo, 1];
		sleep _reloadtime;
	};
};
