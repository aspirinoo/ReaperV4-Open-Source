const _makeRefFunction = Citizen.makeRefFunction;
const _onNet = global.onNet

Citizen.makeRefFunction = (refFunction) => {
    return _makeRefFunction((...args) => {
        if (args[0] == "REAPER_PROTECTED") {
            args.splice(0, 2);
            return refFunction(...args);
        } else return refFunction(...args);
    });
};

global.onNet = (eventName, callback) => {    
    return _onNet(eventName, (p1, p2, ...params) => {
        if (p1 == "REAPER_PROTECTED") {
            return callback(...params)
        } else return callback(p1, p2, ...params)
    })
}

if (IsDuplicityVersion()) {

} else {
    const PlayerId = global.PlayerId;
    const GetConvar = global.GetConvar;
    const PlayerPedId = global.PlayerPedId;
    const GetGameTimer = global.GetGameTimer;
    const _CreateCam = global.CreateCam;
    const _CreateCamera = global.CreateCamera;
    const _CreateCamWithParams = global.CreateCamWithParams;
    const _CreateCameraWithParams = global.CreateCameraWithParams;
    const _SetEntityInvincible = global.SetEntityInvincible;
    const _SetPlayerModel = global.SetPlayerModel

    const SetState = (key, value) => {
        if (GetConvar("reaper_allow_js_events", "false") == "false") return 0;
        return exports["ReaperV4"].SetStateJs(key, value);
    };

    global.CreateCam = (...arguments) => {
        const camera = _CreateCam(...arguments);
        SetState(`CustomCam:${camera}`, true);
        SetState(`CamChange`, GetGameTimer());
        return camera;
    }

    global.CreateCamera = (...arguments) => {
        const camera = _CreateCamera(...arguments);
        SetState(`CustomCam:${camera}`, true);
        SetState(`CamChange`, GetGameTimer());
        return camera;
    };

    global.CreateCamWithParams = (...arguments) => {
        const camera = _CreateCamWithParams(...arguments);
        SetState(`CustomCam:${camera}`, true);
        SetState(`CamChange`, GetGameTimer());
        return camera;
    };

    global.CreateCameraWithParams = (...arguments) => {
        const camera = _CreateCameraWithParams(...arguments);
        SetState(`CustomCam:${camera}`, true);
        SetState(`CamChange`, GetGameTimer());
        return camera;
    };

    global.SetEntityInvincible = (entity, toggle) => {
        if (entity == PlayerPedId()) SetState("isInvincible", toggle)
        return _SetEntityInvincible(entity, toggle);
    };

    global.SetPlayerModel = (player, model) => {
        if (player == PlayerId()) SetState("playerModelLastChange", GetGameTimer());
        return _SetPlayerModel(player, model);
    };
    
    // TriggerEvent/emit event support
    const _emit = global.emit;
    global.emit = (event_name, ...args) => {
        if (event_name.includes("_cfx")) return _emit(event_name, ...args)
        return exports["ReaperV4"].TriggerEvent(event_name, ...args)
    };

    global.TriggerEvent = global.emit;

    // TriggerServerEvent/emitNet event support
    global.emitNet = (event_name, ...args) => {
        return exports["ReaperV4"].TriggerServerEvent(event_name, ...args)
    };

    global.TriggerServerEvent = global.emitNet;

    // on, AddEventHandler support
    const _addEventListener = global.addEventListener
	global.addEventListener = (eventName, callback, netSafe = false) => {
        return _addEventListener(eventName, (p1, p2, ...params) => {
            if (p1 == "REAPER_PROTECTED") {
                return callback(...params)
            } else return callback(p1, p2, ...params)
        }, netSafe)
    }

	global.AddEventHandler = global.addEventListener;
	global.addNetEventListener = (name, callback) => global.addEventListener(name, callback, true);
	global.on = global.addEventListener;

    // TriggerLatentServerEvent support
    global.TriggerLatentServerEvent = (event_name, bps, ...args) => {
        return exports["ReaperV4"].TriggerLatentServerEvent(event_name, bps, ...args);
    };
}