// § boundedQueueVarStatic406
module top;
  int q[$:4];
  int r[$];
  initial begin
    q = '{1, 2, 3};
    r = q[0:1];
  end
endmodule
