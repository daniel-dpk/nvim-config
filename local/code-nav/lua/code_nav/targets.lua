local M = {
  -- Reasonable defaults / "common" names
  ["*"] = { "function_definition", "class_definition" },

  -- Python (tree-sitter-python)
  python = {
    "function_definition",
    "async_function_definition",
    "class_definition",
    "decorated_definition",
  },

  -- Lua (tree-sitter-lua) - there's no classes; functions come in 2 flavors
  lua = {
    "function_declaration",
    "local_function",
  },

  -- C (tree-sitter-c)
  c = {
    "function_definition",
  },

  -- C++ (tree-sitter-cpp)
  cpp = {
    "function_definition",
    "class_specifier",
    "struct_specifier",
    -- (add "namespace_definition" to jump across namespaces)
  },

  -- Cython (to check; names vary by grammar)
  cython = {
    "function_definition",
    "async_function_definition",
    "class_definition",
    "cdef_function_definition",
    "cpdef_function_definition",
  },
}

return M
