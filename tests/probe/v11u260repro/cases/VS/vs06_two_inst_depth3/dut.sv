// § shadowedImportTsRefOwner260 (instance depth 3, two instances, a part-select bound and a replication count)
package rp;
  localparam int OffD = 2;
endpackage
module ctrl import rp::*; (input logic [7:0] a, output logic [3:0] q);
  localparam int OffD = 2;
  always_comb q = {a[OffD:1], {OffD{a[0]}}};
endmodule
module mid (input logic [7:0] a, output logic [3:0] q0, q1);
  ctrl u0 (.a(a), .q(q0));
  ctrl u1 (.a(~a), .q(q1));
endmodule
module top;
  logic [7:0] a; logic [3:0] q0, q1;
  mid m (.a(a), .q0(q0), .q1(q1));
endmodule
