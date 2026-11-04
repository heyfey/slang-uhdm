// § shadowedImportTsRefOwner260 (the top module itself, a nested operand)
package rp;
  localparam int OffD = 2;
endpackage
module top import rp::*; (input logic [7:0] a, output logic [1:0] q);
  localparam int OffD = 2;
  always_comb q = ~(a[1 +: OffD] & 2'b11);
endmodule
