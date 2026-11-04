package p;
class sm;
  int count[string];
  function void bump(string type_id);
    count[type_id]++;
  endfunction
endclass
class user;
  sm seed_map;
  function void f(string type_id);
    seed_map.count[type_id]++;
  endfunction
endclass
endpackage
module top; endmodule
