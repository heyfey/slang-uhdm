// § parenCastWidthRefPkgBare207: the width package imported by a module header (the importing module's elaborated copies) and read in a port range
package p;
  localparam dev_w = 4;
  localparam addr_w = 20;
  localparam wide_a = (dev_w+addr_w)'('h0010_0000);
  localparam base_a = (addr_w)'('h0_1000);
  localparam match_a = (addr_w)'('h0_1???);
endpackage
module top import p::*; (input logic [addr_w-1:0] a, output logic [dev_w-1:0] d);
  assign d = a[dev_w-1:0];
endmodule
