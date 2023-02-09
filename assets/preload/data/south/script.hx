function onSongStart() {
    game.camZooming = true;
    game.camHUD.alpha = 0.3;
    game.defaultCamZoom *= 1.2;
    game.camGame.zoom *= 1.4;
    game.camHUD.zoom *= 1.4;
}

function onBeatHit(c) {
    switch (c) {
        case 16:
            game.defaultCamZoom /= 1.2;
            game.camGame.zoom *= 1.4;
            game.camHUD.zoom *= 1.4;
        case 31:
            game.defaultCamZoom /= 1.05;
        case 32:
            game.defaultCamZoom *= 1.05;
            game.camGame.zoom *= 1.4;
            game.camHUD.zoom *= 1.4;
            game.camHUD.alpha = 1;
    }
}