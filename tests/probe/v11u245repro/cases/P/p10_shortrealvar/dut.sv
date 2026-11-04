// § unitRealTdElabShares245
// a $unit shortreal and real typedef on module variables inside a child, instanced twice
typedef shortreal sr_t;
typedef real r_t;
module sub;
  sr_t a;
  r_t b;
  initial begin a = 1.5; b = 2.5; end
endmodule
module top;
  sub u1();
  sub u2();
endmodule
