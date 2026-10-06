// § shadowedImportTsRefOwner260 (a continuous assignment, an indexed part-select width)
package rp;
  localparam int OffD = 2;
endpackage
module ctrl import rp::*; (input logic [7:0] a, output logic [1:0] q);
  localparam int OffD = 2;
  assign q = a[1 +: OffD];
endmodule
module top;
  logic [7:0] a; logic [1:0] q;
  ctrl u (.a(a), .q(q));
endmodule
