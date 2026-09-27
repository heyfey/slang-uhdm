package p;
class sm;
  int cnt;
endclass
function int f();
  sm seed_map;
  seed_map = new;
  seed_map.cnt++;
  return 0;
endfunction
endpackage
module top; endmodule
