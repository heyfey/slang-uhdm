// § unboundEventImplicitNet403
module child; event e; initial -> e; endmodule
module top;
  child u();
  initial @(u.e) $display("x");
endmodule
