// § shadowedImportTsRefOwner260 (a system-call argument and a replication count)
package rp;
  localparam int OffD = 2;
endpackage
module ctrl import rp::*; (input logic [7:0] a, output logic [7:0] q);
  localparam int OffD = 2;
  always_comb begin : nb
    q = {OffD{1'b1}} | 8'($clog2(OffD));
  end
endmodule
module top;
  logic [7:0] a, q;
  ctrl u (.a(a), .q(q));
endmodule
