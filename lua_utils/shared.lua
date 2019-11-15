--A lua library for shared functions between CI scripts

--We want instant output!
io.stdout:setvbuf("no")
io.stderr:setvbuf("no")

local GITHUB_WORKSPACE = os.getenv("GITHUB_WORKSPACE")
assert(GITHUB_WORKSPACE, "This library has to be used inside of Github Actions environment!")

function fixPath(path)
    if path:sub(1,1) ~= "/" then path = "/"..path end
    return GITHUB_WORKSPACE..path
end

--== Shell Utilities ==--

--Escape a path or some data
function escape(...)
    local str = table.concat({...}, " ")
    return string.format("%q", str)
end

--Executes a command, and makes errors on exitCodes > 0
function execute(...)
    local cmd = table.concat({...}," ")
    local exitCode = os.execute(cmd)
    if exitCode > 0 then
        return error("Failed to execute "..cmd)
    end
end

--Executes a command, and returns it's output
function capture(cmd, raw)
    local f = assert(io.popen(cmd, 'r'))
    local s = assert(f:read('*a'))
    f:close()
    if raw then return s end
    s = string.gsub(s, '^%s+', '')
    s = string.gsub(s, '%s+$', '')
    s = string.gsub(s, '[\n\r]+', ' ')
    return s
end

--Executes chmod on the file
function chmod(path, mode)
    mode = mode or "+x"
    path = fixPath(path)

    local exitCode = os.execute("chmod "..mode.." "..path)
    assert(exitCode, "Failed to execute chmod", mode, path)
end

--Downloads a file using wget, automatically appends the destination to GITHUB_WORKSPACE
function wget(url, destination)
    local exitCode = os.execute(string.format('wget -v -O %q %q', fixPath(destination), url))
    assert(exitCode == 0, "Failed to download "..url.." into "..destination)
end

--== File Utilities ==--

fs = {}

--Read the whole content of a file
function fs.read(path)
    local file = assert(io.open(fixPath(path),"rb"))
    local data = file:read("*a")
    file:close()

    return data
end

--Write data into a new file, or overriding an existing one
function fs.write(path, data)
    local file = assert(io.open(fixPath(path),"wb"))
    file:write(data)
    file:flush()
    file:close()
end

--== Commands based FS ==--

--Rename a file or a directory
function fs.rename(from, to)
    from, to = escape(fixPath(from)), escape(fixPath(to))
    execute("mv","-f","-v",from,to)
end

--Copy a file or a directory
function fs.copy(from, to)
    from, to = escape(fixPath(from)), escape(fixPath(to))
    execute("cp","-f","-v","-r",from,to)
end

--Remove a file or a directory
function fs.remove(path)
    path = escape(fixPath(path))
    execute("rm","-f","-v","-r",path)
end

--== Git Utilities ==--
--Returns a sorted list of the git tags set.
function getTags()
    local tags = capture("git tag --list")
    local list = {}
    for tag in string.gmatch("(%S) ") do
        table.insert(list, tag)
    end
    table.sort(list)
    return list
end

--Returns the biggest tag
function getLatestTag()
    return capture("git describe --abbrev=0 --tags"):gsub("%w", "")
end

--Returns the tag we are running on, or nil when not tagged
function getTag()
    local tagged = GITHUB_REF:sub(1,10) == "refs/tags/"
    if not tagged then return false end

    return GITHUB_REF:sub(11,-1)
end


--== Shared Constants ==--

LOVE_VERSION = fs.read("LOVE_VERSION.txt")
LIKO_VERSION = fs.read("LIKO_VERSION.txt")
ANDROID_VERSION_CODE = fs.read("ANDROID_VERSION_CODE.txt")

GITHUB_REPOSITORY = os.getenv("GITHUB_REPOSITORY")
GITHUB_REF = os.getenv("GITHUB_REF")

do local pos = GITHUB_REPOSITORY:find("/")
    USER = GITHUB_REPOSITORY:sub(1,pos-1)
    REPO = GITHUB_REPOSITORY:sub(pos+1,-1)
end

LINUX_PLATFORMS = {"x86_64"}