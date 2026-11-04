// § unboundEventImplicitNet403
module child; event e; endmodule
module top;
  child u();
  initial -> u.e;
endmodule
