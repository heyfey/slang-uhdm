// § parenCastWidthRefPkgBare207: a paren-cast width parameter of a package imported by a module that uses only the width parameter
package p;
  localparam dw = 4;
  localparam m = (dw)'('hf);
endpackage
module top(output logic [3:0] o);
  import p::dw;
  assign o = dw;
endmodule
