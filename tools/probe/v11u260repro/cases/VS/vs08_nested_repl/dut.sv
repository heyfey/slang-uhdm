// § shadowedImportTsRefOwner260 (a replication count inside another replication, a continuous assignment)
package rp;
  localparam int OffD = 2;
endpackage
module ctrl import rp::*; (input logic a, output logic [3:0] q);
  localparam int OffD = 2;
  assign q = {2{ {OffD{a}} }};
endmodule
module top;
  logic a; logic [3:0] q;
  ctrl u (.a(a), .q(q));
endmodule
