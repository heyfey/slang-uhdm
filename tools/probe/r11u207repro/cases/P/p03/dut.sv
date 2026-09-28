// § parenCastWidthRefPkgBare207: a module-body wildcard import in two modules, one instantiating the other
package p;
  localparam addr_w = 16;
  localparam base_a = (addr_w)'('h0_1000);
  localparam match_a = (addr_w)'('h0_1???);
endpackage
module sub(input logic [15:0] x, output logic [15:0] y);
  import p::*;
  logic [addr_w-1:0] r;
  assign y = x;
endmodule
module top(input logic [15:0] x, output logic [15:0] y);
  import p::*;
  sub u(.x(x), .y(y));
endmodule
