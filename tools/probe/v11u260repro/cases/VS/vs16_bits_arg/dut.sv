// § shadowedImportTsRefOwner260 (the fold as $bits / $signed argument)
package rp;
  localparam logic [3:0] OffD = 4'd2;
endpackage
module ctrl import rp::*; (input logic [7:0] a, output logic [7:0] q);
  localparam logic [3:0] OffD = 4'd2;
  assign q = a + $bits(OffD) + $unsigned(OffD);
endmodule
module top;
  logic [7:0] a, q;
  ctrl u (.a(a), .q(q));
endmodule
