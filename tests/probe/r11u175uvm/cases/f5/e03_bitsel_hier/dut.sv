package p1;
  class holder;
    int count[string];
    string args[$];
  endclass
  class user;
    holder seed_map;
    function int get(string type_id, int i);
      seed_map.count[type_id] = 1;
      return seed_map.args[i].len();
    endfunction
  endclass
endpackage
module top;
  import p1::*;
  user u;
  initial begin u = new; void'(u.get("a", 0)); end
endmodule
