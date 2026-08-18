// r10vbuvm24repro/gv24f.sv — NEGATIVE CONTROL: a SEQUENCE instance with an
// empty slot (the `SequenceInst` corpus shape).  MEASUREMENT ONLY.
module sqv24 (input logic clk1, input logic clk2, input logic d);
  sequence sq_multi(ev1, ev2, ev3, ev4);
    @(ev1) d ##1 @(ev3) d;
  endsequence
  aprop: assert property (sq_multi(negedge clk2, , posedge clk1, ));
endmodule
