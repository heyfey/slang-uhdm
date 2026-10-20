// § realtimeVarIsTime414
module top;
  parameter realtime P = 1.5;
  localparam realtime Q = 2.5;
  initial $display(P, Q);
endmodule
