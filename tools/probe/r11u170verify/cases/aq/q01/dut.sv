// § arrQueryFoldAtBound158
module top #(parameter logic [3:0][7:2] P = '0) (output logic [7:0] o);
  localparam int H1 = $high(P);
  localparam int H2 = $high(P, 2);
  localparam int L2 = $left(P, 2);
  localparam int R1 = $right(P);
  assign o = H1 + H2 + L2 + R1;
endmodule
