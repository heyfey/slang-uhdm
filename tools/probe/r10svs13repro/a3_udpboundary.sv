// r10svs13 arm a3 — SEPARATE "UDP-SHAPED" FROM "TWO OR MORE ORDERED TERMINALS".
//
// a1's udp-shaped cells all happen to have two ordered terminals, so a1 alone
// cannot tell the two candidate gates apart.  Every cell here has an ORDERED
// list of exactly TWO terminals and an interface-ARRAY port; only the FIRST
// terminal's form (and the `#()` override's form) moves the udp-shape verdict:
//
//   s1  first terminal is an OPERATION      -> NOT udp-shaped  (2 ordered terms)
//   s2  first terminal is a net_lvalue      ->     udp-shaped
//   s3  first terminal MISSING (empty)      -> NOT udp-shaped  (2 ordered terms)
//   s4  `#(1)` ordered 1-value override     ->     udp-shaped  (still delay2)
//   s5  `#(1,2,3)` ordered 3-value override -> NOT udp-shaped  (exceeds delay2)
//   s6  `#(.W(1))` NAMED override           -> NOT udp-shaped
//
// Each cell is instantiated for BOTH parent kinds where the def allows it.
interface oif(input bit clock);
  logic [7:0] d;
  modport OP(input clock, output d);
endinterface

program leafmixp(input bit x, oif.OP a[4]);
endprogram
module leafmixm(input bit x, oif.OP a[4]);
endmodule
program leaf2pP #(int W = 1) (oif.OP a[4], oif.OP b);
endprogram
program leaf3pP #(int W = 1, int X = 2, int Y = 3) (oif.OP a[4], oif.OP b);
endprogram
module leaf2mP #(int W = 1) (oif.OP a[4], oif.OP b);
endmodule
module leaf3mP #(int W = 1, int X = 2, int Y = 3) (oif.OP a[4], oif.OP b);
endmodule

module top();
bit Clock;
oif arr[4](Clock);
oif sc(Clock);

leafmixp s1p(Clock & 1'b1, arr);
leafmixm s1m(Clock & 1'b1, arr);
leafmixp s2p(Clock, arr);
leafmixm s2m(Clock, arr);
leafmixp s3p(, arr);
leafmixm s3m(, arr);
leaf2pP #(1) s4p(arr, sc);
leaf2mP #(1) s4m(arr, sc);
leaf3pP #(1,2,3) s5p(arr, sc);
leaf3mP #(1,2,3) s5m(arr, sc);
leaf3pP #(.W(1)) s6p(arr, sc);
leaf3mP #(.W(1)) s6m(arr, sc);
endmodule
