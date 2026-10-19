// § boundedQueueVarStatic406
class C;
  int q [$:4];
endclass
module top;
  function automatic int f();
    int lq [$:2];
    lq.push_back(1);
    return lq.size();
  endfunction
  C c;
  int x;
  initial x = f();
endmodule
