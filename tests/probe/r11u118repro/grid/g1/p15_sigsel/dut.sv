module top (input logic [15:0] i, output logic [7:0] o);
  assign o = i[7:0];
endmodule
