// § shadowedImportTsRefOwner260 (a replication count in a named block)
package rp;
  localparam int OffD = 3;
endpackage
module ctrl import rp::*; (input logic [7:0] a, output logic [7:0] q);
  localparam int OffD = 3;
  always_comb begin : nb
    q = {5'b0, {OffD{1'b1}}};
  end
endmodule
module top;
  logic [7:0] a, q;
  ctrl u (.a(a), .q(q));
endmodule
