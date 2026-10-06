// § shadowedImportTsRefOwner260 (a declaration's dimension bound and a part-select bound in one module)
package rp;
  localparam int OffD = 2;
endpackage
module ctrl import rp::*; (input logic [7:0] a, output logic [2:0] q);
  localparam int OffD = 2;
  logic [OffD:0] v;
  assign v = a[OffD:0];
  assign q = v;
endmodule
module top;
  logic [7:0] a; logic [2:0] q;
  ctrl u (.a(a), .q(q));
endmodule
