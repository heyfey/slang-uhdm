// r11u30 arm b2 (`[$:$]` REMOVED: slang refuses the source outright -- "value
// range cannot be unbounded on both sides" -- so no arm can be built on it) — the MEMBER-SHAPE grid of an open-range set: unbounded bounds,
// several plain members beside several ranges, compound bounds on both sides,
// string / 4-state / sized literals, a select and a hierarchical bound, a
// function-call bound, and an `inside` nested inside another `inside`.
module c30;
  localparam int NA30 = 1;
  localparam int NB30 = 6;
  int aq30 [$];
  int n30, m30;
  logic [7:0] bv30;
  string s30;
  function automatic int f30(int x30); return x30 + 1; endfunction
  function automatic bit m1(int zv); return zv inside {[1:$]};          endfunction
  function automatic bit m2(int zv); return zv inside {[$:9]};          endfunction
  function automatic bit m4(int zv); return zv inside {1, 2, [4:6], 8, 9}; endfunction
  function automatic bit m5(int zv); return zv inside {[NA30+1:NB30*2]}; endfunction
  function automatic bit m6(int zv); return zv inside {[f30(1):f30(2)]}; endfunction
  function automatic bit m7(int zv); return zv inside {aq30[0], [2:3], n30}; endfunction
  function automatic bit m8(logic [7:0] zv); return zv inside {8'b1010_10?0, [8'h10:8'h20]}; endfunction
  function automatic bit m9(string zv); return zv inside {"aa", "bb"};  endfunction
  function automatic bit ma(int zv); return (zv inside {[1:2]}) inside {[0:1]}; endfunction
  function automatic bit mb(int zv); return zv inside {[m30:m30]};      endfunction
  function automatic bit mc(int zv); return zv inside {NA30, [NB30:9]}; endfunction
  function automatic bit md(int zv); return zv inside {n30 + 1, [2:3]};  endfunction
  function automatic bit me(int zv); return zv inside {[n30+1:4], 7};    endfunction
endmodule
