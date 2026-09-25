// § arrQueryFoldAtBound158
module sub #(parameter logic [1:6] P = '0) (output logic [7:0] o);
  localparam int H = $high(P);
  localparam int L = $left(P);
  assign o = H * 8 + L;
endmodule
module top (output logic [7:0] o, output logic [7:0] o2);
  sub u(.o(o));
  sub #(.P(6'd3)) u2(.o(o2));
endmodule
