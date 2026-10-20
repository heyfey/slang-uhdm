// § realtimeVarIsTime414
module top;
  realtime a, b;
  initial begin a = $realtime; b = a; end
endmodule
