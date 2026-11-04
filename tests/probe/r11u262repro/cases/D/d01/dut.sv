// § shareDefParamTsOwnNotImport262 (a part-select bound: Earlgrey testflags #604623, from r11u260repro S/s03_part_sel)
package rp;
  localparam int OffD = 3;
endpackage
module ctrl import rp::*; (input logic [7:0] a, output logic [7:0] q);
  localparam int OffD = 3;
  always_comb q = {4'b0, a[OffD:0]};
endmodule
module top;
  logic [7:0] a, q;
  ctrl u (.a(a), .q(q));
endmodule
