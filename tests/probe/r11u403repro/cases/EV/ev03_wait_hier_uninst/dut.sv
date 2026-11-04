// § unboundEventWaitSpan403
module inner();
  initial
    @top.e;
endmodule
module top();
  event e;
  initial -> e;
endmodule
