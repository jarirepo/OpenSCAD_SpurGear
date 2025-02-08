
// https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Other_Language_Features#search
function find_prop_index(prop_name, arr) =
  search([prop_name], arr, num_returns_per_match = 1, index_col_num = 0)[0];

function find_prop_value(prop_name, arr) =
  arr[search([prop_name], arr, num_returns_per_match = 1, index_col_num = 0)[0]][1];
