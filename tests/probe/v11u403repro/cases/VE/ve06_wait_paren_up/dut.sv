// § unboundEventWaitSpan403
module inner;
  initial @(top.e) $display("y");
endmodule
module top;
  event e;
  inner i();
  initial -> e;
endmodule
