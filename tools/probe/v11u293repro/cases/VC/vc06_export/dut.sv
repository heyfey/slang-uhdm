// § cloneRetNameSelRefBindsHomeReturn293
// The importer re-exports the home.
package p1;
  function logic [7:0] f();
    f = 8'h0;
    f[6] = 1'b1;
    f = ~f;
  endfunction
endpackage
package p2;
  import p1::*;
  export p1::*;
  function logic [7:0] g();
    return f();
  endfunction
endpackage
module top;
  import p2::*;
  int r_o;
  initial r_o = int'(g());
endmodule
