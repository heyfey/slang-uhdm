// § cloneRetNameSelRefBindsHomeReturn293
// CONTROL: a module wildcard-imports the home (no package clone).
package p1;
  function logic [7:0] f();
    f = 8'h0;
    f[3] = 1'b1;
    f = f | 8'h80;
  endfunction
endpackage
module top;
  import p1::*;
  int r_o;
  initial r_o = int'(f());
endmodule
