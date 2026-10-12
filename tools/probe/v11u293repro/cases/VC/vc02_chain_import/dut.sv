// § cloneRetNameSelRefBindsHomeReturn293
// A chain of wildcard importers.
package p1;
  function logic [7:0] f();
    f = 8'h0;
    f[5] = 1'b1;
    f = f + 8'd2;
  endfunction
endpackage
package p2;
  import p1::*;
  function logic [7:0] g();
    return f();
  endfunction
endpackage
package p3;
  import p2::*;
  import p1::*;
  function logic [7:0] h();
    return g() + f();
  endfunction
endpackage
module top;
  import p3::*;
  int r_o;
  initial r_o = int'(h());
endmodule
