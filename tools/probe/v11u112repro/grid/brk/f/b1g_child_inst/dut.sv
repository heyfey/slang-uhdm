package pk; parameter int unsigned P = 3; endpackage
module c import pk::*; #(parameter int W = 8) (input logic [W-1:0] a, output logic y);
  assign y = a[P-1] ^ a[W-P];
endmodule
module top (input logic [7:0] a, output logic y1, y2);
  c u1(.a(a), .y(y1));
  c #(.W(6)) u2(.a(a[5:0]), .y(y2));
endmodule
