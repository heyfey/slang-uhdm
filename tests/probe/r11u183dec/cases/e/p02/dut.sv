package p;
class sm;
  int count[string];
endclass
function int f(string type_id);
  sm seed_map;
  seed_map = new;
  seed_map.count[type_id]++;
  return 0;
endfunction
endpackage
module top; endmodule
