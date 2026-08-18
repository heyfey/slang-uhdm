package vip19;
  int gv19[string];
  function void f19();
    foreach (gv19[i]) $display("iv", gv19[i]);
    gv19["a"] = 1;
  endfunction
endpackage
module vmi19;
  import vip19::*;
  initial f19();
endmodule
module vtopi19;
  vmi19 u0();
  vmi19 u1();
  vmi19 u2();
endmodule
