module top(input logic [7:0] b, output logic [7:0] y1, y2);
  /* start
     0     inside */ assign y1 = 5     | b;
  assign y2 = b;
endmodule
