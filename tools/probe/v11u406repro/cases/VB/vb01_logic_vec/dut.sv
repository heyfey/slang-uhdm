// § boundedQueueVarStatic406
module top;
  logic [7:0] q [$:3];
  initial q.push_back(8'h1);
endmodule
