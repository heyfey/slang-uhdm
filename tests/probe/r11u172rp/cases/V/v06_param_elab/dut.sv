module sub #(parameter int W = 8) (input logic [W-1:00] i, output logic [W-1:00] o);
  assign o = i;
endmodule
module top (input logic [3:0] i, output logic [3:0] o);
  sub #(.W(4)) u (.i(i), .o(o));
endmodule
