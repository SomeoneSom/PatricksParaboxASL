//by atpx8
//special thanks to Ero for putting up with my absolute stupidity while making this and also finding the pointers for congratsAnimT
//NOTE: REQUIRES UnityASL.bin (https://github.com/just-ero/asl-help/blob/main/libraries/UnityASL.bin)

state("Patrick's Parabox") {
}

startup
{
	vars.Log = (Action<object>)(output => print("[Patrick's Parabox] " + output));
	vars.Unity = Assembly.Load(File.ReadAllBytes(@"Components\UnityASL.bin")).CreateInstance("UnityASL.Unity");
	// vars.Unity.LoadSceneManager = true;
	
	settings.Add("intrortt", false, "Intro Return To Title");
	settings.Add("any", true, "Any%");
	settings.Add("all", false, "100%");
	settings.Add("ilany", false, "Any% ILs");
	settings.Add("ilall", false, "100% ILs");
	settings.Add("credits", false, "Credits Split in 100%");
	settings.Add("ending", false, "Only Split at End");
}


init
{
	vars.Unity.TryOnLoad = (Func<dynamic, bool>)(helper =>
	{
		var list = helper.GetClass("mscorlib", "List`1");
		var world = helper.GetClass("Assembly-CSharp", "World");
		var draw = helper.GetClass("Assembly-CSharp", "Draw");
		var floor = helper.GetClass("Assembly-CSharp", "Floor");
		var savef = helper.GetClass("Assembly-CSharp", "SaveFile");
		var saved = helper.GetClass("Assembly-CSharp", "SaveData", 1);

		vars.Unity.Make<byte>(world.Static, world["EndZoom"]).Name = "worldEnding";
		vars.Unity.Make<int>(draw.Static, draw["TitleT"]).Name = "drawTitleT";
		vars.Unity.Make<float>(world.Static, world["celebrationT"]).Name = "worldPerfect";
		vars.Unity.Make<byte>(world.Static, world["unlocking"]).Name = "gateUnlocking";
		vars.Unity.Make<float>(world.Static, world["floors"], list["_items"], 0x20 + 0x8 * 0x4A, floor["AnimT"]).Name = "congratsAnimT";
		vars.Unity.MakeString(savef.Static, savef["Current"], saved["RecentArea"]).Name = "recent";
		vars.Unity.Make<int>(world.Static, world["State"]).Name = "worldState";

		return true;
	});
	vars.splitcount = 0;
	vars.splittypesany = new int[] {
		3,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		2
	};
	vars.splittypesall = new int[] {
		3,
		3,
		3,
		3,
		3,
		3,
		3,
		3,
		3,
		3,
		3,
		3,
		3,
		3,
		3,
		3,
		3,
		3,
		4,
		3,
		3,
		3,
		3,
		3,
		5
	};

	vars.Unity.Load(game);
}

update
{
	if (!vars.Unity.Loaded) return false;

	if (timer.CurrentPhase == TimerPhase.NotRunning && vars.splitcount != 0)
	{
    		vars.splitcount = 0;
	}

	if (vars.splitcount == 18 && !settings["credits"]) {
		vars.splitcount++;
	}


	vars.Unity.Update();
	current.Credits = vars.Unity["worldEnding"].Current;
	current.TitleT = vars.Unity["drawTitleT"].Current;
	current.Hundred = vars.Unity["worldPerfect"].Current;
	current.Unlocking = vars.Unity["gateUnlocking"].Current;
	current.AnimT = vars.Unity["congratsAnimT"].Current;
	current.State = vars.Unity["worldState"].Current;
	current.Recent = vars.Unity["recent"].Current;

	// current.Scene = vars.Unity.Scenes.Active.Index;
}

start
{
	return old.TitleT == 0 && current.TitleT > 0;
}

split
{
	if (!vars.Unity.Loaded) return false;
	int type = -1;
	if (settings["ending"]) {
		if (settings["any"] && (old.Credits == 0 && current.Credits == 1)) {
			vars.splitcount++;
			return true;
		} else if (settings["all"] && (old.AnimT == 0 && current.AnimT > 0)) {
			vars.splitcount++;
			return true;
		} else {
			return false;
		}
	} else if (settings["intrortt"] && vars.splitcount == 0) {
		if (current.Recent == "Area_Enter") {
			vars.splitcount++;
			return true;
		} else {
			return false;
		}
	}
	if (settings["any"]) {
		type = vars.splittypesany[vars.splitcount];
	} else if (settings["all"]) {
		type = vars.splittypesall[vars.splitcount];
	} else if (settings["ilany"]) {
		type = 0;
	} else if (settings["ilall"]) {
		type = 3;
	} else {
		type = vars.splittypesany[vars.splitcount];
	}

	if (type == 0 && (old.Unlocking == 1 && current.Unlocking == 0)) {
		vars.splitcount++;
		return true;
	} else if (type == 2 && (old.Credits == 0 && current.Credits == 1)) {
		vars.splitcount++;
		return true;
	} else if (type == 3 && (old.Hundred > 0 && current.Hundred == 0)) {
		vars.splitcount++;
		return true;
	} else if (type == 4 && (old.State == 3 && current.State == 1)) {
		vars.splitcount++;
		return true;
	} else if (type == 5 && (old.AnimT == 0 && current.AnimT > 0)) {
		vars.splitcount++;
		return true;
	} else {
		return false;
	}
}

reset
{}

gameTime
{}

isLoading
{}

exit
{
	vars.Unity.Reset();
}

shutdown
{
	vars.Unity.Reset();
}