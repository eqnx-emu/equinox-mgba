#include "paths.hpp"

#include "doctest/doctest.h"

TEST_CASE("srm path uses zip name") {
    CHECK(srmPath("/switch/equinox/saves/gba", "/roms/gba/Super Metroid (USA).zip") ==
          "/switch/equinox/saves/gba/Super Metroid (USA).srm");
}

TEST_CASE("srm path tolerates trailing slash") {
    CHECK(srmPath("/s/", "/r/a.gba") == "/s/a.srm");
}

TEST_CASE("stem keeps dots inside name") {
    CHECK(romStem("/roms/Mr. Do!.gba") == "Mr. Do!");
    CHECK(romStem("C:\\roms\\Mr. Do!.gba") == "Mr. Do!");
    CHECK(romStem("noext") == "noext");
}

TEST_CASE("state path") {
    CHECK(statePath("/st", "/r/Game.zip") == "/st/Game.state");
}

TEST_CASE("video prefs path uses zip name") {
    CHECK(videoPrefsPath("sdmc:/s", "sdmc:/r/Chrono Trigger (USA).zip") ==
          "sdmc:/s/Chrono Trigger (USA).video.json");
}
