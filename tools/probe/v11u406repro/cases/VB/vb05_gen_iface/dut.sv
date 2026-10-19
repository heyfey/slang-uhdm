// § boundedQueueVarStatic406
interface bus;
  int q [$:2];
endinterface
module top;
  bus b0();
  if (1) begin : g
    int q [$:5];
  end
endmodule
