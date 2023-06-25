//by atpx8
//special thanks to Ero for putting up with my absolute stupidity while making this and also finding the pointers for congratsAnimT
//NOTE: REQUIRES UnityASL.bin (https://github.com/just-ero/asl-help/blob/main/lib/UnityASL.bin)

state("Patrick's Parabox") {
}

startup
{
	vars.levelsWon = 0;

	vars.Log = (Action<object>)(output => print("[Patrick's Parabox] " + output));
	vars.Unity = Assembly.Load(File.ReadAllBytes(@"Components\UnityASL.bin")).CreateInstance("UnityASL.Unity");
	// vars.Unity.LoadSceneManager = true;

	//structure here:
	//key: area name
	//tuple vals in order: anim skip option name, any% split option name, 100% split option name,
	//any% split type, 100% split type, any% level amount, 100% level amount, area name to split at if anim skipped
	vars.splitdict = new Dictionary<string, Tuple<string, string, string, int, int, int, int, Tuple<string>>> {
		{"Area_Intro", Tuple.Create("intrortt", "introany", "introall", 3, 3, 9, 9, "Area_Enter")},
		{"Area_Enter", Tuple.Create("enterrtt", "enterany", "enterall", 0, 3, 12, 18, "Area_Empty")},
		{"Area_Empty", Tuple.Create("emptyrtt", "emptyany", "emptyall", 0, 3, 7, 14, "Area_Eat")},
		{"Area_Eat", Tuple.Create("eatrtt", "eatany", "eatall", 0, 3, 9, 13, "Area_Reference")},
		{"Area_Reference", Tuple.Create("refrtt", "refany", "refall", 0, 3, 5, 12, "Area_Swap")},
		{"Area_Swap", Tuple.Create("swaprtt", "swapany", "swapall", 0, 3, 1, 5, "Area_Center")},
		{"Area_Center", Tuple.Create("centerrtt", "centerany", "centerall", 0, 3, 7, 16, "Area_Clone")},
		{"Area_Clone", Tuple.Create("clonertt", "cloneany", "cloneall", 0, 3, 13, 25, "Area_Transfer")},
		{"Area_Transfer", Tuple.Create("transrtt", "transany", "transall", 0, 3, 14, 29, "Area_Open")},
		{"Area_Open", Tuple.Create("openrtt", "openany", "openall", 0, 3, 4, 12, "Area_Flip")},
		{"Area_Flip", Tuple.Create("fliprtt", "flipany", "flipall", 0, 3, 8, 17, "Area_Cycle")},
		{"Area_Cycle", Tuple.Create("cyclertt", "cycleany", "cycleall", 0, 3, 9, 18, "Area_Player")},
		{"Area_Player", Tuple.Create("playerrtt", "playerany", "playerall", 0, 3, 14, 24, "Area_Possess")},
		{"Area_Possess", Tuple.Create("possrtt", "possany", "possall", 0, 3, 9, 22, "Area_Wall")},
		{"Area_Wall", Tuple.Create("wallrtt", "wallany", "wallall", 0, 3, 6, 15, "Area_InfiniteExit")},
		{"Area_InfiniteExit", Tuple.Create("exitrtt", "exitany", "exitall", 0, 3, 10, 18, "Area_InfiniteEnter")},
		{"Area_InfiniteEnter", Tuple.Create("ienterrtt", "ienterany", "ienterall", 0, 3, 10, 20, "Area_MultiInfinite")},
		{"Area_MultiInfinite", Tuple.Create("multirtt", "multiany", "multiall", 2, 3, 0, 11, "Area_Reception")},
		{"Area_Challenge", Tuple.Create("challrtt", "challany", "challall", 4, 3, 0, 38, "Area_Reception")},
		{"Area_Gallery", Tuple.Create("gallrtt", "gallany", "gallall", 4, 3, 0, 3, "Area_Reception")},
		{"Area_Priority", Tuple.Create("prirtt", "priany", "priall", 4, 3, 0, 9, "Area_Appendix")},
		{"Area_Extrude", Tuple.Create("extrtt", "extany", "extall", 4, 3, 0, 8, "Area_Appendix")},
		{"Area_Push", Tuple.Create("pushrtt", "pushany", "pushall", 4, 3, 0, 8, "Area_Appendix")}
	};

	string[] names = {"Intro", "Enter", "Empty", "Eat", "Reference", "Swap", "Center", "Clone", "Transfer", "Open", "Flip",
			"Cycle", "Player", "Possess", "Wall", "Infinite Exit", "Infinite Enter", "Multi Infinite",
			"Challenge", "Gallery", "Priority", "Extrude", "Inner Push"};

	settings.Add("any", true, "Any%");
	settings.Add("all", false, "100%");
	settings.Add("rtt", false, "Split On Next Area");
	for (int i = 0; i < vars.splitdict.Count; i++) {
		string name = names[i];
		if (name == "Infinite Exit") {
			name = "InfiniteExit";
		} else if (name == "Infinite Enter") {
			name = "InfiniteEnter";
		} else if (name == "Multi Infinite") {
			name = "MultiInfinite";
		} else if (name == "Inner Push") {
			name = "Push";
		}
		name = "Area_" + name;
		var data = vars.splitdict[name];
		if (data.Item4 != 4 && data.Item4 != 2) {
			settings.Add(data.Item2, true, names[i], "any");
		}
		settings.Add(data.Item1, false, names[i], "rtt");
		settings.Add(data.Item3, false, names[i], "all");
	}
	settings.Add("credits", false, "Credits Split in 100%");
	settings.Add("room", false, "Split Individual Levels in Area");
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
		vars.Unity.Make<byte>(world.Static, world["Winning"]).Name = "winning";

		return true;
	});

	vars.Unity.Load(game);

	current.Recent = "";
}

update
{
	if (!vars.Unity.Loaded) return false;


	vars.Unity.Update();
	current.Credits = vars.Unity["worldEnding"].Current;
	current.TitleT = vars.Unity["drawTitleT"].Current;
	current.Hundred = vars.Unity["worldPerfect"].Current;
	current.Unlocking = vars.Unity["gateUnlocking"].Current;
	current.AnimT = vars.Unity["congratsAnimT"].Current;
	current.State = vars.Unity["worldState"].Current;
	current.Recent = vars.Unity["recent"].Current;
	current.Winning = vars.Unity["winning"].Current;

	if (old.Recent == "Area_Reception" || old.Recent == "Area_Appendix" || old.Recent == "") {
		return;
	}

	var data = vars.splitdict[old.Recent];

	int max = 0;
	if (settings["any"]) {
		max = data.Item6;
	} else if (settings["all"]) {
		max = data.Item7;
	}

	if (current.Recent != old.Recent && vars.levelsWon >= max) {
		vars.levelsWon = 0;
	}

	// current.Scene = vars.Unity.Scenes.Active.Index;
}

start
{
	return old.TitleT == 0 && current.TitleT > 0;
}

split
{
	if (!vars.Unity.Loaded) return false;

	//special case for reception and appendix
	if (old.Recent == "Area_Reception" || old.Recent == "Area_Appendix") {
		//special case for reception
		if (old.Recent == "Area_Reception" && settings["all"] && (old.AnimT == 0 && current.AnimT > 0)) {
			return true;
		}
		return false;
	}

	//special case for credits in 100%
	if (settings["all"] && settings["credits"] && (current.Credits == 1 || old.State == 3)) {
		return old.State == 3 && current.State == 1;
	}

	//split data
	var data = vars.splitdict[old.Recent];

	//check if this split is even enabled
	if (settings["any"]) {
		if (data.Item4 == 4 || data.Item4 == 2) {
			//special case for type 2
			if (data.Item4 == 2 && (old.Credits == 0 && current.Credits == 1)) {
				return true;
			}
			return false;
		} else if (!settings[data.Item2]) {
			return false;
		}
	} else if (settings["all"]) {
		if (!settings[data.Item3]) {
			return false;
		}
	} else {
		return false; //this means no options are checked
	}

	//get level requirement
	int max = 0;
	if (settings["any"]) {
		max = data.Item6;
	} else if (settings["all"]) {
		max = data.Item7;
	}

	//check for room splits
	if (settings["room"] && (vars.levelsWon < max)) {
		if (old.Winning == 1 && current.Winning == 0) {
			vars.levelsWon++;
			return true;
		}
		return false;
	}

	//check for anim skip
	if (settings[data.Item1] && current.Recent == data.Rest.Item1) {
		return true;
	}
	if (settings[data.Item1]) {
		return false;
	}

	//get split type
	int type = 0;
	if (settings["any"]) {
		type = data.Item4;
	} else if (settings["all"]) {
		type = data.Item5;
	}

	//check for gate unlock if split type is any%
	if (type == 0) {
		return (old.Unlocking == 1 && current.Unlocking == 0);
	}

	//check for celebration end if split type is 100%
	if (type == 3) {
		return (old.Hundred > 0 && current.Hundred == 0);
	}
	
	return false;
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
