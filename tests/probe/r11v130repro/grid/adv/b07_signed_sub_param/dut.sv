// § netSigningTsSpan130
module sub #(parameter W = 4) (input logic [W-1:0] i, output logic [W-1:0] o);
  wire signed [W-1:0] t;
  assign t = i;
  assign o = t >>> 1;
endmodule
module top(input logic [7:0] i, output logic [7:0] o);
  sub #(.W(8)) u(.i(i), .o(o));
endmodule
