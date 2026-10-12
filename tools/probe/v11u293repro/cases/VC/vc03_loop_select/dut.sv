// § cloneRetNameSelRefBindsHomeReturn293
// Select writes in a loop.
package p1;
  function logic [7:0] f();
    f = 8'h0;
    for (int j = 0; j < 4; j++) f[j] = 1'b1;
    f = f >> 1;
  endfunction
endpackage
package p2;
  import p1::*;
  function logic [7:0] g();
    return f();
  endfunction
endpackage
module top;
  import p2::*;
  int r_o;
  initial r_o = int'(g());
endmodule
