// r10svs13 VERIFIER arm v2 — THE OVER-FIRE CELL: can a PROGRAM ever OWN an
// interface_array in golden?  The pass's §3.4 asserts LRM 24.3 forbids an
// interface instantiation inside a program, so the ONLY interface_array a
// program can carry is a PORT VIEW.  MEASURE it instead of citing it.
interface oif(input bit clock);
  logic [7:0] d;
  modport OP(input clock, output d);
endinterface

program progloc(input bit clock);
  oif loc[2](clock);          // a LOCALLY DECLARED interface ARRAY inside a program
endprogram
module modloc(input bit clock);
  oif loc[2](clock);          // the module control
endmodule

module top();
bit Clock;
progloc g1(Clock);
modloc  g2(Clock);
endmodule
