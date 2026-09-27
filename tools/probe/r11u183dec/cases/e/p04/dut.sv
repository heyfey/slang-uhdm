package p;
class sm;
  int count[string];
endclass
function int f(string type_id);
  sm seed_map;
  int x;
  seed_map = new;
  x = seed_map.count[type_id];
  return x;
endfunction
endpackage
module top; endmodule
