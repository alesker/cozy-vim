local M = {}

local notify = require("mason-core.notify")
local registry = require("mason-registry")

local function install_package(package_name)
  local _, package = pcall(registry.get_package, package_name)
  if not package:is_installed() and not package:is_installing() then
    notify(("[mason.nvim] installing %s"):format(package_name))

    package:install(
      {},
      vim.schedule_wrap(function(success, _)
        if success then
          notify(("[mason.nvim] %s was successfully installed"):format(package_name))
        else
          notify(
            ("[mason.nvim] failed to install %s. Installation logs are available in :Mason and :MasonLog"):format(
              package_name
            ),
            vim.log.levels.ERROR
          )
        end
      end)
    )
  end
end

function M.ensure_installed(ensure_installed)
  for _, package in ipairs(ensure_installed) do
    if registry.has_package(package) then
      install_package(package)
    else
      notify(("[mason.nvim] Package %q is not a valid entry in ensure_installed."):format(package), vim.log.levels.WARN)
    end
  end
end

return M
