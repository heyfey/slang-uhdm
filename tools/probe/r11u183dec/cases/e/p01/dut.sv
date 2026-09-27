package p;
class sm;
  int count[string];
  int seed_table[string];
endclass
function int f(string type_id);
  sm seed_map;
  seed_map = new;
  seed_map.count[type_id] = 0;
  seed_map.seed_table[type_id] = seed_map.seed_table[type_id]+seed_map.count[type_id];
  seed_map.count[type_id]++;
  return seed_map.seed_table[type_id];
endfunction
endpackage
module top; endmodule
