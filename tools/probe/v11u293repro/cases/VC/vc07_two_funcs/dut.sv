// § cloneRetNameSelRefBindsHomeReturn293
// Two home functions, one calling the other.
package p1;
  function logic [7:0] f();
    f = 8'h0;
    f[1] = 1'b1;
    f = f + 8'd1;
  endfunction
  function logic [7:0] f2();
    f2 = f();
    f2[0] = 1'b0;
    f2 = f2 << 2;
  endfunction
endpackage
package p2;
  import p1::*;
  function logic [7:0] g();
    return f2();
  endfunction
endpackage
module top;
  import p2::*;
  int r_o;
  initial r_o = int'(g());
endmodule
