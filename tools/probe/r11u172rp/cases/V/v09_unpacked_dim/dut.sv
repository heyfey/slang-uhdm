module top (input logic [7:0] i, output logic [7:0] o);
  logic [7:0] m [00:03];
  assign m[0] = i;
  assign o = m[0];
endmodule
