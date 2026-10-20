// § realtimeVarIsTime414
module sub(input realtime t);
endmodule
module top;
  realtime r;
  sub u(.t(r));
endmodule
