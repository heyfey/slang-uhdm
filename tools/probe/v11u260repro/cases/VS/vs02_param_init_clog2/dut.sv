// § shadowedImportTsRefOwner260 (a system-call argument in a body localparam initializer, then used as a width)
package rp;
  localparam int OffD = 4;
endpackage
module ctrl import rp::*; (input logic [7:0] a, output logic [7:0] q);
  localparam int OffD = 4;
  localparam int Y = $clog2(OffD);
  assign q = {a[Y-1:0], {(8-Y){1'b0}}};
endmodule
module top;
  logic [7:0] a, q;
  ctrl u (.a(a), .q(q));
endmodule
