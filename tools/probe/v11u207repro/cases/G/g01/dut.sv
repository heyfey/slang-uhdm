// § parenCastWidthRefPkgBare207: paren-cast widths inside a package function body and a package parameter, the package imported by nothing
package p;
  localparam dw = 8;
  localparam aw = 12;
  localparam base = (aw)'('h100);
  function automatic logic [dw-1:0] f(int x); return (dw)'(x); endfunction
endpackage
module top(output logic [7:0] o);
  assign o = p::f(3);
endmodule
