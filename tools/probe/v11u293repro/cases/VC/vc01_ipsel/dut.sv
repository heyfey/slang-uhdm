// § cloneRetNameSelRefBindsHomeReturn293
// An indexed part-select write of the return name.
package p1;
  function logic [7:0] f(input int k);
    f = 8'h0;
    f[k +: 2] = 2'b11;
    f = f ^ 8'h1;
  endfunction
endpackage
package p2;
  import p1::*;
  function logic [7:0] g();
    return f(2);
  endfunction
endpackage
module top;
  import p2::*;
  int r_o;
  initial r_o = int'(g());
endmodule
