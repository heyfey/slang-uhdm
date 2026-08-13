// r10svs11 arm c3 — THE INTERFACE-ARRAY connection-site net, same axes.
//
// The producer mints the connection-site net in TWO loops: one for a scalar
// interface instance passed to a scalar interface port, one for a whole
// interface ARRAY passed to an interface-ARRAY port.  SVSwitch's witness
// carries BOTH (`mem_intf`/`input_intf` scalar, `output_intf[4]` array) in one
// list, so a fix applied to only one loop would clear two thirds of the head
// and leave the third — this arm keeps the array axis separately measurable.
//
// Cells cross the same connection-list shape against the ARRAY actual, and add
// the element-select and modport-qualified forms the producer already excludes,
// so a regression in those is visible here too.
interface ifa(input bit clk);
  logic sig;
  modport MP(input clk, output sig);
endinterface

module a1m (ifa.MP m[4]);                     logic q; endmodule
module a2m (ifa.MP m[4], ifa.MP n[4]);        logic q; endmodule
module a3m (ifa.MP m[4], input logic a);      logic q; endmodule
module s1m (ifa.MP m);                        logic q; endmodule

module top();

bit Clock;

ifa g1i[4](Clock);
ifa g2a[4](Clock); ifa g2b[4](Clock);
ifa g3i[4](Clock);
ifa g4i[4](Clock);
ifa g5i[4](Clock);
ifa g6i[4](Clock);

// f1 array actual, 1 ordered terminal              -> NOT udp-shaped
a1m v1 (g1i);
// f2 array actual, 2 ordered terminals             -> UDP-SHAPED
a2m v2 (g2a, g2b);
// f3 array actual, NAMED connection                -> NOT udp-shaped
a1m v3 (.m(g3i));
// f4 array actual FIRST, regular second, ordered   -> UDP-SHAPED
a3m v4 (g4i, Clock);
// f5 ELEMENT SELECT of an array, 1 ordered terminal (producer excludes '[')
s1m v5 (g5i[0]);
// f6 array actual, 1 ordered terminal, NAMED-list control
a1m v6 (.m(g6i));

endmodule
