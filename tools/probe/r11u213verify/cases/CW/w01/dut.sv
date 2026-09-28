// § parenCastWidthRefPkgBare207 (the width parameter explicitly imported by a module; the cast parameter imported by another)
package pk;
  localparam aw = 12;
  localparam base = (aw)'('h100);
endpackage
module m1 (output logic [11:0] o);
  import pk::aw;
  assign o = aw;
endmodule
module top (output logic [11:0] o, output logic [11:0] b);
  import pk::base;
  m1 u (.o(o));
  assign b = base;
endmodule
