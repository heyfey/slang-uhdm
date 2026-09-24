// r10vbuvm24repro/gv24b.sv — NEGATIVE CONTROL: a MODULE INSTANCE port list
// with an empty connection (the `ImplicitPorts2` corpus shape).  Not a
// subroutine-call argument; must not move.  MEASUREMENT ONLY.
module leafv24 (input a, input b, input c);
  wire x = a & b & c;
endmodule

module negv24;
  wire aa, bb, cc;
  leafv24 u0 (aa, , cc);
  leafv24 u1 (.a(aa), .b(), .c(cc));
endmodule
