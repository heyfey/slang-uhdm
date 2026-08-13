// r10svs14 VERIFIER ARM 3 — the last kind § 6.9 named and did not measure.
interface c1_if(input chandle h); logic d; modport mp(input h, d); endinterface
module z1(c1_if.mp p); endmodule
module top; chandle hh; c1_if c1(hh); z1 w1(c1); endmodule
