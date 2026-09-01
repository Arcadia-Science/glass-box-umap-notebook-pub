--[[
additional-assets – render an "Additional assets" row from document metadata.

Mirrors the "Additional assets" component on The Stacks including its fixed asset vocabulary
and its icon set.

Authors declare assets in the notebook's YAML front matter as structured
records:

    ---
    title: "..."
    additional-assets:
      - type: code
        url: https://github.com/Arcadia-Science/my-pub
      - type: protocol
        url: https://www.protocols.io/view/...
        name: Cell culture protocol
    ---
]]

local stringify = pandoc.utils.stringify

-- The Stacks' LinkedAssetType enum, in its canonical display order.
local TYPES = {
  { key = "code",          label = "Code",               icon = "code" },
  { key = "data",          label = "Data",               icon = "graph" },
  { key = "code-and-data", label = "Code + data",        icon = "code-and-data" },
  { key = "material",      label = "Material",           icon = "test-tube" },
  { key = "protocol",      label = "Protocol",           icon = "list" },
  { key = "3d-printing",   label = "3D printing design", icon = "print-3d" },
  { key = "companion-pub", label = "Companion pub",      icon = "book" },
  { key = "other",         label = "Other",              icon = "add" },
}

-- Spellings an author might write
local ALIASES = {
  ["code-data"]           = "code-and-data",
  ["code-plus-data"]      = "code-and-data",
  ["3d"]                  = "3d-printing",
  ["3d-print"]            = "3d-printing",
  ["3d-printing-design"]  = "3d-printing",
  ["companion"]           = "companion-pub",
  ["companion-pub"]       = "companion-pub",
  ["companion-publication"] = "companion-pub",
  ["dataset"]             = "data",
  ["repo"]                = "code",
  ["repository"]          = "code",
  ["reagent"]             = "material",
}

-- Icons lifted from The Stacks' icon set
local ICONS = {
  code = {
    viewBox = "0 0 18 9",
    body = [[<path d="M0 5.1211L5.41408 7.91017V6.48048L1.7461 4.64063L5.41408 2.80078V1.38281L0 4.17188V5.1211Z" fill="currentColor"/><path d="M6.77344 8.12111H8.14454L11.2734 0H9.90235L6.77344 8.12111Z" fill="currentColor"/><path d="M11.8594 1.38281V2.80078L15.5508 4.64063L11.8594 6.48048V7.91017L17.2735 5.1211V4.16016L11.8594 1.38281Z" fill="currentColor"/>]],
  },
  graph = {
    viewBox = "0 0 14 14",
    body = [[<path d="M0.155273 9.29299L4.12794 7.9922L8.42873 2.78906L10.4092 5.07422L12.8936 2.87109" stroke="currentColor" stroke-miterlimit="10" fill="none"/><path d="M0.424805 0V13.1016H12.3194" stroke="currentColor" stroke-width="0.75" stroke-miterlimit="10" fill="none"/>]],
  },
  list = {
    viewBox = "0 0 28 28",
    body = [[<path d="M8.16667 10.5003V8.16699H24.5V10.5003H8.16667ZM8.16667 15.167V12.8337H24.5V15.167H8.16667ZM8.16667 19.8337V17.5003H24.5V19.8337H8.16667ZM4.66667 10.5003C4.33611 10.5003 4.05903 10.3885 3.83542 10.1649C3.61181 9.9413 3.5 9.66421 3.5 9.33366C3.5 9.0031 3.61181 8.72602 3.83542 8.50241C4.05903 8.2788 4.33611 8.16699 4.66667 8.16699C4.99722 8.16699 5.27431 8.2788 5.49792 8.50241C5.72153 8.72602 5.83333 9.0031 5.83333 9.33366C5.83333 9.66421 5.72153 9.9413 5.49792 10.1649C5.27431 10.3885 4.99722 10.5003 4.66667 10.5003ZM4.66667 15.167C4.33611 15.167 4.05903 15.0552 3.83542 14.8316C3.61181 14.608 3.5 14.3309 3.5 14.0003C3.5 13.6698 3.61181 13.3927 3.83542 13.1691C4.05903 12.9455 4.33611 12.8337 4.66667 12.8337C4.99722 12.8337 5.27431 12.9455 5.49792 13.1691C5.72153 13.3927 5.83333 13.6698 5.83333 14.0003C5.83333 14.3309 5.72153 14.608 5.49792 14.8316C5.27431 15.0552 4.99722 15.167 4.66667 15.167ZM4.66667 19.8337C4.33611 19.8337 4.05903 19.7219 3.83542 19.4982C3.61181 19.2746 3.5 18.9975 3.5 18.667C3.5 18.3364 3.61181 18.0594 3.83542 17.8357C4.05903 17.6121 4.33611 17.5003 4.66667 17.5003C4.99722 17.5003 5.27431 17.6121 5.49792 17.8357C5.72153 18.0594 5.83333 18.3364 5.83333 18.667C5.83333 18.9975 5.72153 19.2746 5.49792 19.4982C5.27431 19.7219 4.99722 19.8337 4.66667 19.8337Z" fill="currentColor"/>]],
  },
  ["test-tube"] = {
    viewBox = "0 0 8 17",
    body = [[<path d="M7.86 1.308C7.86 0.588 7.272 0 6.552 0H1.308C0.588 0 0 0.588 0 1.308C0 1.764 0.252 2.148 0.6 2.376V6.468C0.6 8.268 0.888 10.044 1.452 11.748L2.736 15.588C2.904 16.104 3.372 16.452 3.924 16.452C4.476 16.452 4.944 16.116 5.112 15.588L6.396 11.748C6.96 10.044 7.248 8.268 7.248 6.468V2.376C7.608 2.136 7.848 1.764 7.848 1.308H7.86ZM1.308 0.96H6.552C6.744 0.96 6.9 1.116 6.9 1.308C6.9 1.5 6.744 1.644 6.564 1.656H1.296C1.104 1.656 0.96 1.5 0.96 1.308C0.96 1.116 1.116 0.96 1.308 0.96ZM5.916 9.84C4.812 9.852 3.204 9.84 1.932 9.84C1.692 8.736 1.56 7.62 1.56 6.48V2.628H6.3V6.48C6.3 7.62 6.168 8.736 5.928 9.84H5.916Z" fill="currentColor"/>]],
  },
  ["print-3d"] = {
    viewBox = "0 0 10 17",
    body = [[<path d="M0.839846 15.5117V10.3555H5.98439V9.85156L6.19534 9.64062H0.125V16.2149H5.98439V15.5117H0.839846Z" fill="currentColor" stroke="currentColor" stroke-width="0.25" stroke-miterlimit="10"/><path d="M9.62891 6.71094H9.12501L6.19531 9.64063H6.69921V10.1445L8.91406 7.92969V12.7813L6.69921 15.0078V16.0156L9.62891 13.0742V6.71094Z" fill="currentColor" stroke="currentColor" stroke-width="0.25" stroke-miterlimit="10"/><path d="M6.69922 10.1445V9.64062H6.19532L5.98438 9.85156V10.3555V15.5117V16.2149H6.48829L6.69922 16.0156V15.0078V10.1445Z" fill="currentColor" stroke="currentColor" stroke-width="0.25" stroke-miterlimit="10"/><path d="M9.62892 7.42579H4.51953V4.36719H5.23438V6.71094H9.62892V7.42579Z" fill="currentColor" stroke="currentColor" stroke-width="0.25" stroke-miterlimit="10"/><path d="M6.16017 3.86329L4.87109 5.10548L3.59375 3.86329V0.125H6.16017V3.86329Z" fill="currentColor" stroke="currentColor" stroke-width="0.25" stroke-miterlimit="10"/>]],
  },
  book = {
    viewBox = "0 0 40 40",
    body = [[<path d="M18.31,34.83V12.01h0c-3.56-4.38-8.39-6.84-13.42-6.84h-1.41v22.83h1.41c5.03,0,9.86,2.46,13.42,6.84h0Z" fill="currentColor"/><path d="M21.69,34.83V12.01h0c3.56-4.38,8.39-6.84,13.42-6.84h1.41v22.83h-1.41c-5.03,0-9.86,2.46-13.42,6.84h0Z" fill="currentColor"/>]],
  },
  add = {
    viewBox = "0 0 13 13",
    body = [[<path d="M12.936 5.712H7.212V0H5.712V5.712H0V7.212H5.712V12.936H7.212V7.212H12.936V5.712Z" fill="currentColor"/>]],
  },
}

local TYPE_BY_KEY, TYPE_ORDER = {}, {}
for i, t in ipairs(TYPES) do
  TYPE_BY_KEY[t.key] = t
  TYPE_ORDER[t.key] = i
end

local function escape_html(s)
  return (s:gsub("[&<>\"]", { ["&"] = "&amp;", ["<"] = "&lt;", [">"] = "&gt;", ['"'] = "&quot;" }))
end

--- Detect an unexpanded Quarto shortcode (e.g. `{{< var pub.org >}}`).
--- This filter runs before Quarto expands them, and `stringify` drops them
--- silently, so a URL containing one would render subtly wrong.
local function has_shortcode(inlines)
  if type(inlines) ~= "table" then return false end
  for _, el in ipairs(inlines) do
    if el.t == "Span" and el.attributes and el.attributes["__quarto_custom"] then
      return true
    end
  end
  return false
end

--- Map whatever the author wrote onto one of the canonical type keys.
local function resolve_type(raw)
  local key = raw:lower():gsub("%s+", "-"):gsub("_", "-"):gsub("[^%w%-+]", "")
  key = key:gsub("%+", "-and-"):gsub("%-%-+", "-"):gsub("^%-", ""):gsub("%-$", "")
  -- Try the key as written, then its alias, then the same two de-pluralized.
  local singular = key:gsub("s$", "")
  local candidates = { key, ALIASES[key], singular, ALIASES[singular] }
  for i = 1, 4 do
    local c = candidates[i]
    if c and TYPE_BY_KEY[c] then return TYPE_BY_KEY[c] end
  end
  return nil
end

--- One circular icon badge.
local function badge(icon_name)
  local icon = ICONS[icon_name]
  return string.format(
    '<span class="additional-asset-badge additional-asset-badge-%s">'
      .. '<svg viewBox="%s" xmlns="http://www.w3.org/2000/svg" aria-hidden="true" focusable="false">%s</svg>'
      .. '</span>',
    icon_name, icon.viewBox, icon.body
  )
end

--- One asset chip: badge(s) plus a monospace label, wrapped in its link.
local function chip(asset)
  local icons
  if asset.type.icon == "code-and-data" then
    -- The Stacks pairs the two icons inside a single outlined pill.
    icons = '<span class="additional-asset-pair">' .. badge("code") .. badge("graph") .. "</span>"
  else
    icons = badge(asset.type.icon)
  end

  return string.format(
    '<a class="additional-asset" href="%s" rel="noopener">'
      .. '%s<span class="additional-asset-name">%s</span></a>',
    escape_html(asset.url), icons, escape_html(asset.name)
  )
end

--- Read the `additional-assets` metadata into a sorted list of assets.
local function read_assets(meta)
  local raw = meta["additional-assets"]
  if not raw or #raw == 0 then return {} end

  local assets = {}
  for _, entry in ipairs(raw) do
    local type_key = entry.type and stringify(entry.type) or ""
    local url = entry.url and stringify(entry.url) or ""
    local asset_type = resolve_type(type_key)

    -- Shortcodes are not supported in these URLs: they are still unexpanded
    -- when this filter runs, and would be dropped silently. Fail loudly instead.
    if entry.url and has_shortcode(entry.url) then
      quarto.log.warning(
        "additional-assets: shortcodes such as {{< var >}} are not supported in "
          .. "asset URLs. Write the URL literally instead. Got: '" .. url .. "'"
      )
    end

    if url == "" then
      quarto.log.warning("additional-assets: skipping entry with no `url`.")
    elseif not asset_type then
      quarto.log.warning(
        "additional-assets: unknown type '" .. type_key .. "', falling back to 'other'."
      )
      asset_type = TYPE_BY_KEY.other
    end

    if url ~= "" and asset_type then
      local name = entry.name and stringify(entry.name) or ""
      table.insert(assets, {
        type = asset_type,
        url = url,
        -- A name, when given, replaces the type label — that is how you
        -- distinguish two assets of the same type (e.g. two protocols).
        name = name ~= "" and name or asset_type.label,
        order = #assets,
      })
    end
  end

  -- Group by type the way The Stacks does, preserving author order within a type.
  table.sort(assets, function(a, b)
    if TYPE_ORDER[a.type.key] ~= TYPE_ORDER[b.type.key] then
      return TYPE_ORDER[a.type.key] < TYPE_ORDER[b.type.key]
    end
    return a.order < b.order
  end)

  return assets
end

function Pandoc(doc)
  if not quarto.doc.is_format("html:js") then return nil end

  local assets = read_assets(doc.meta)
  if #assets == 0 then return nil end

  local chips = {}
  for _, asset in ipairs(assets) do
    table.insert(chips, chip(asset))
  end

  -- A plain div, not <aside>: Quarto routes <aside> into the margin column.
  local html = '<div class="additional-assets">'
    .. '<p class="additional-assets-label">Additional assets:</p>'
    .. '<div class="additional-assets-list">'
    .. table.concat(chips)
    .. "</div></div>"

  table.insert(doc.blocks, 1, pandoc.RawBlock("html", html))
  return doc
end
