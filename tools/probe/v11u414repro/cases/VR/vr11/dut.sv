// § realtimeVarIsTime414
module top;
  realtime q[$];
  realtime d[];
  initial $display(q.size(), d.size());
endmodule
