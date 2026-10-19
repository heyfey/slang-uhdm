// § boundedQueueVarStatic406
module child #(parameter int M = 3);
  byte q [$:M];
endmodule
module top;
  child #(5) c1();
  child c2();
endmodule
