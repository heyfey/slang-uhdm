// § unboundEventImplicitNet403
module inner;
  initial ->> top.e;
endmodule
module top;
  event e;
  inner i();
endmodule
