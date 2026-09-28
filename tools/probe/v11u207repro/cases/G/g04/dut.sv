// § parenCastWidthRefPkgBare207: a package re-exporting another package's paren-cast width parameter, no module importer
package p;
  localparam dw = 4;
  localparam m = (dw)'('hf);
endpackage
package q;
  import p::*;
  export p::*;
  localparam z = (dw)'('h2);
endpackage
module top; endmodule
