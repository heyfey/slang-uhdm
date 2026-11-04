// § unboundEventImplicitNet403
module inner();
  initial begin
    ->> top.e;
    -> top.f;
  end
endmodule
module top();
  event e, f;
endmodule
