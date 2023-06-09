local U = {};

-- This function try to import a module, if it fails
-- throw an error.
U.require = function(pkg)
    local ok, imported_pkg = pcall(require, pkg)
    if not ok then
        error(string.format("Couldn't load '%s'", pkg))
    end

    return imported_pkg
end

return U
