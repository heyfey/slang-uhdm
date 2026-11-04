// § shadowedImportTsRefOwner260 (a body wildcard import, the indexed part-select width)
package rp;
  localparam int OffD = 2;
endpackage
module ctrl (input logic [7:0] a, output logic [1:0] q);
  import rp::*;
  localparam int OffD = 2;
  assign q = a[2 +: OffD];
endmodule
module top;
  logic [7:0] a; logic [1:0] q;
  ctrl u (.a(a), .q(q));
endmodule
