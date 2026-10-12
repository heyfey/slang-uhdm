// § cloneRetNameSelRefBindsHomeReturn293
// A part-select write of the return name.
package p1;
  function logic [7:0] f();
    f = 8'h0;
    f[3:0] = 4'h5;
    f = f + 1;
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
