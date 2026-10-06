// § shadowedImportTsRefOwner260 (a macro-born indexed part-select width)
`define SEL(x) x[1 +: OffD]
package rp;
  localparam int OffD = 3;
endpackage
module ctrl import rp::*; (input logic [7:0] a, output logic [7:0] q);
  localparam int OffD = 3;
  always_comb q = {5'b0, `SEL(a)};
endmodule
module top;
  logic [7:0] a, q;
  ctrl u (.a(a), .q(q));
endmodule
