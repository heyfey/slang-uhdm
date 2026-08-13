// r10svs13 arm a2 — THE SCALAR-ACTUAL TWIN (Interfaces(), not Interface_arrays()).
//
// Same axes as a1 but every interface port is SCALAR, so the vector under test
// is `Interfaces()` — the field program::Compare reaches IMMEDIATELY BEFORE
// Interface_arrays() and the one that produces the identical one-sided
// `LHS: <null>` head signature.  The witness pair is measured null on BOTH
// sides for the SVSwitch program; this arm asks whether that is a law or an
// accident of that test's shape.
interface oif(input bit clock);
  logic [7:0] d;
  modport OP(input clock, output d);
endinterface

module leaf2ms(oif.OP a, oif.OP b);
endmodule
program leaf2ps(oif.OP a, oif.OP b);
endprogram
module leaf1ms(oif.OP a);
endmodule
program leaf1ps(oif.OP a);
endprogram

module top();
bit Clock;
oif sc(Clock);
oif sd(Clock);

leaf2ps q1(sc, sd);
leaf2ps q2(.a(sc), .b(sd));
leaf1ps q3(sc);
leaf1ps q4(.a(sc));
leaf2ms n1(sc, sd);
leaf2ms n2(.a(sc), .b(sd));
leaf1ms n3(sc);
leaf1ms n4(.a(sc));
endmodule
