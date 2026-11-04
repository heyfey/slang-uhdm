module top(input logic [7:0] b, x12, output logic [7:0] y1, y2);
  assign y1 = x12     | b;
  assign y2 = b[1:0]     == 2'b01 ? b : x12;
endmodule
