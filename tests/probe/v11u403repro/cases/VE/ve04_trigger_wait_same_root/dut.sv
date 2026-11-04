// § unboundEventWaitSpan403
module inner;
  initial begin
    @top.e;
    -> top.f;
    @top.f;
  end
endmodule
module top;
  event e, f;
  inner i();
endmodule
