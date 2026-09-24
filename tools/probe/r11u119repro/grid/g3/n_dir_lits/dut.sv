`define UNUSED_M 1
module top(input logic [7:0] b, input logic c, output logic [7:0] y1, y2, y3, y4, y5, y6, y7, y8, y9, y10, y11, y12, y13, y14);
  assign y1 = 'x     | b;
  assign y2 = 'z     | b;
  assign y3 = '0     | b;
  assign y4 = '1     | b;
  assign y5 = 0     | b;
  assign y6 = 8'hFF     | b;
  assign y7 = 'hFF     | b;
  assign y8 = 4'b10     | b;
  assign y9 = 8'h A5 | b;
  assign y10 = 8 'hA5 | b;
  assign y11 = 12  -1 | b;
  assign y12 = 'X     | b;
  assign y13 = 'sd3     | b;
  assign y14 = 3'd5 | b;
endmodule
