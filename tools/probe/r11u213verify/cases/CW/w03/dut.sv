// § parenCastWidthRefPkgBare207 (a module localparam of the same name shadowing the package's width parameter; a class in the package with a paren cast)
package pk;
  localparam dw = 4;
  localparam m = (dw)'('hf);
  class C;
    function logic [dw-1:0] f(int x); return (dw)'(x); endfunction
  endclass
endpackage
module top (output logic [7:0] o, output logic [3:0] q);
  import pk::*;
  localparam dw = 8;
  assign o = dw;
  assign q = m;
endmodule
