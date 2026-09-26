package p1;
  class base;
    extern function void g(
      input int a,
      output int b,
      inout bit [2:0] c
    );
  endclass
  function void base::g(input int a, output int b, inout bit [2:0] c);
    b = a;
  endfunction
endpackage
module top;
  import p1::*;
  base bb;
  int y; bit [2:0] z;
  initial begin bb = new; bb.g(1, y, z); end
endmodule
