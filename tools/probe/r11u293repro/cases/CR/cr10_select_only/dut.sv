// § cloneRetNameSelRefBindsHomeReturn293
// Only select writes, no bare reference: nothing to move.
package p1;
  function logic [3:0] f();
    f[0] = 1'b1;
    f[3:1] = 3'b0;
  endfunction
endpackage
package p2;
  import p1::*;
  function logic [3:0] g();
    return f();
  endfunction
endpackage
module top;
  import p2::*;
  int r_o;
  initial r_o = int'(g());
endmodule
