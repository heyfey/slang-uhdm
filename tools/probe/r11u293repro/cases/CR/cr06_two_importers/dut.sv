// § cloneRetNameSelRefBindsHomeReturn293
// Two packages wildcard-import the same home.
package p1;
  function logic [7:0] f();
    f = 8'h0;
    f[4] = 1'b1;
    f = f | 8'h1;
  endfunction
endpackage
package p2;
  import p1::*;
  function logic [7:0] g();
    return f();
  endfunction
endpackage
package p3;
  import p1::*;
  function logic [7:0] h();
    return f() + 1;
  endfunction
endpackage
module top;
  import p2::*;
  import p3::*;
  int r_o;
  initial r_o = int'(g());
  int r_q;
  initial r_q = int'(h());
endmodule
