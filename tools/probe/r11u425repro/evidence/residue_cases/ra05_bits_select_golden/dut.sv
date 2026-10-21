// this ground, decoded not written: golden's $bits of a select is the whole signal's width ($bits(a[2:0]) = 4, $bits(a[1]) = 4), v11u421 VB/vb14
module top (input logic [3:0] a, output logic [7:0] o);
  localparam W = $bits(a[2:0]);
  localparam V = $bits(a[1]);
  assign o = W + V;
endmodule
