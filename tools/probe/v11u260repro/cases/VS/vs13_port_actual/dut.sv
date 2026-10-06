// § shadowedImportTsRefOwner260 (an indexed part-select width in a port actual)
package rp;
  localparam int OffD = 2;
endpackage
module sub (input logic [1:0] x, output logic y);
  assign y = ^x;
endmodule
module ctrl import rp::*; (input logic [7:0] a, output logic q);
  localparam int OffD = 2;
  sub s (.x(a[3 +: OffD]), .y(q));
endmodule
module top;
  logic [7:0] a; logic q;
  ctrl u (.a(a), .q(q));
endmodule
