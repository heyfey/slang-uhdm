// § cloneRetNameSelRefBindsHomeReturn293
// An explicit return of the return name after a select write.
package p1;
  function automatic logic [7:0] f(input logic [7:0] a);
    f = a;
    f[7] = 1'b0;
    return f;
  endfunction
endpackage
package p2;
  import p1::*;
  function logic [7:0] g();
    return f(8'hff);
  endfunction
endpackage
module top;
  import p2::*;
  int r_o;
  initial r_o = int'(g());
endmodule
