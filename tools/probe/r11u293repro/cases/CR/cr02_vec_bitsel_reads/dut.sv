// § cloneRetNameSelRefBindsHomeReturn293
// A packed-vector return: bare reads and a bit-select write in the clone body.
package p1;
  function logic [7:0] f(input int k);
    f = 8'h0;
    if (f == 8'h0) f[k] = 1'b1;
    return f;
  endfunction
endpackage
package p2;
  import p1::*;
  function logic [7:0] g();
    return f(3);
  endfunction
endpackage
module top;
  import p2::*;
  int r_o;
  initial r_o = int'(g());
endmodule
