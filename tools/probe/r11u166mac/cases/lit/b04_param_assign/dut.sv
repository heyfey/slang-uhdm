// § ppBasedLitWsAfter166
module top(output [7:0] o);
  parameter logic [7:0] OFF = 8'h 0;
  parameter logic [7:0] OFF2 = 8'h 4;
  assign o = OFF + OFF2;
endmodule
