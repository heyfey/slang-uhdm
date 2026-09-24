module top(input logic [7:0] b, output logic [7:0] y1, y2);
  /* 8'hFF     block */ assign y1 = 3     | b;
  initial $display("7     %d", b);
  assign y2 = b; // 4     trailing
endmodule
