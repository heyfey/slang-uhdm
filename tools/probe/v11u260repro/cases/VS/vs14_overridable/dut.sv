// § shadowedImportTsRefOwner260 (an overridable header parameter shadows the package's, overridden in one instance)
package rp;
  localparam int OffD = 2;
endpackage
module ctrl import rp::*; #(parameter int OffD = 2) (input logic [7:0] a, output logic [3:0] q);
  assign q = 4'(a[0 +: OffD]);
endmodule
module top;
  logic [7:0] a; logic [3:0] q0, q1;
  ctrl u0 (.a(a), .q(q0));
  ctrl #(.OffD(3)) u1 (.a(a), .q(q1));
endmodule
