// § unboundEventWaitSpan403
module inner(output logic o);
  always @top.e o = 1;
endmodule
module top;
  event e;
  logic o;
  inner i(o);
endmodule
