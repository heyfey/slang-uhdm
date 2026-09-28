// § parenCastWidthRefPkgBare207: two packages each with their own paren-cast width parameter, one parameter used as width by the other package with a scoped name (not a paren identifier)
package p;
  localparam dw = 4;
  localparam m = (dw)'('hf);
endpackage
package q;
  localparam dw = 6;
  localparam n = (dw)'('h3);
  localparam k = (p::dw)'('h1);
endpackage
module top; endmodule
