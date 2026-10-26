// § connOpUnitParamFold433
localparam [3:0] S = 4'd9;
module child(input [7:0] a, output [7:0] y);
  assign y = a;
endmodule
module top(input [255:0] x, output [7:0] y0, y1, y2);
  child c0(.a(S), .y(y0));
  child c1(.a(x + S), .y(y1));
  child c2(.a(x[S]), .y(y2));
endmodule
