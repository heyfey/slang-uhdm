// r10svs11 VERIFIER arm v3 — the ARRAY loop's OWN empty cells.
// c3 measures the array actual FIRST (f4) but never SECOND, and never the
// ifaceConnNet ANCHOR question for an ARRAY (the array loop shares that map).
interface ifa(input bit clk);
  logic sig;
  modport MP(input clk, output sig);
endinterface

module a1m (ifa.MP m[4]);                 logic q; endmodule
module a2m (ifa.MP m[4], ifa.MP n[4]);    logic q; endmodule
module a3m (input logic a, ifa.MP m[4]);  logic q; endmodule

module top();
bit Clock;
ifa h1[4](Clock);
ifa h2[4](Clock);
ifa h3[4](Clock);
// t1  ARRAY actual SECOND in a udp-shaped ordered list (identifier first)
a3m t1 (Clock, h1);
// t2/t3  ONE array at TWO sites: udp-shaped FIRST, NAMED second
a2m t2 (h2, h3);
a1m t3 (.m(h2));
endmodule
