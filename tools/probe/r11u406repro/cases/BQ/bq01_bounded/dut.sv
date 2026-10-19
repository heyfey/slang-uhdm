// § boundedQueueVarStatic406
module top;
  int q[$:2];
  initial begin
    q.push_back(1);
    $display(q.size);
  end
endmodule
