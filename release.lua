#!/usr/bin/luajit
--A script for uploading the releases into GitHub using github-release

local GITHUB_WORKSPACE = os.getenv("GITHUB_WORKSPACE") --Get the github workspace location
assert(GITHUB_WORKSPACE, "This script has to be used inside of Github Actions environment!")
dofile(GITHUB_WORKSPACE.."/lua_utils/shared.lua") --Load the shared utilities

--== Upload Templates ==--

local templates = {
    ["love_win32.zip"] = "LIKO-12_Windows_i686.zip",
    ["love_win64.zip"] = "LIKO-12_Windows_x86_64.zip",
    ["love_linux/LIKO-12-x86_64.AppImage"] = "LIKO-12_Linux_x86_64.AppImage",
    ["love_macos/love_macos.zip"] = "LIKO-12_macOS.zip",
    ["love_android/love_android.apk"] = "LIKO-12_Android.apk"
}

local tag = getTag()

if not tag then
    print("Not running on a tag, terminating release creation.")
    return
end

print("Installing github-release")
wget("https://github.com/tfausak/github-release/releases/download/1.2.4/github-release-linux.gz", "github-release.gz")
execute("gunzip",fixPath("github-release.gz"))
chmod("github-release")

local GITHUB_TOKEN = os.getenv("GITHUB_TOKEN")
local function quote(str) return "'"..str.."'" end --Surround the string with ''

--Create a new draft release
do
    local command = {
        fixPath("github-release"), "release",
        "--title", quote("Build Templates "..os.date("%Y%m%d",os.time())),
        "--description", quote("### LÖVE Version: "..LOVE_VERSION),
        "--owner", quote(USER),
        "--repo", quote(REPO),
        "--tag", quote(tag),
        "--token", quote(GITHUB_TOKEN)
    }

    command = table.concat(command, " ")
    execute(command)

    print("Created release", tag)
end

--Upload a file into github releases
local function upload(path, name)
    local command = {
        fixPath("github-release"), "upload",
        "--owner", quote(USER),
        "--repo", quote(REPO),
        "--tag", quote(tag),
        "--name", quote(name),
        "--file", quote(fixPath(path)),
        "--token", quote(GITHUB_TOKEN)
    }

    command = table.concat(command, " ")
    execute(command)
end

for path, name in pairs(templates) do
    upload(path, name)
    print("Uploaded", name)
end

print("Uploading releases complete!")