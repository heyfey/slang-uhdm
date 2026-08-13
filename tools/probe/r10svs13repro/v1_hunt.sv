// r10svs13 VERIFIER arm v1 — EMPTY PRODUCT CELL HUNT for § progPortIfaceArrayUnowned13.
// Cells the pass did NOT write:
//   w*  .* WILDCARD connection (the exact shape that broke r10svs12's stated gate)
//   x*  TWO interface-ARRAY ports on ONE program (two wrappers, both unowned)
//   y*  a program TWO levels down (module -> module -> program)
//   z*  the port dimension forms: [1] (nElem narrowing) and [3:0] (msb:lsb)
interface oif(input bit clock);
  logic [7:0] d;
  modport OP(input clock, output d);
endinterface

program  leaf2p (oif.OP a[4], oif.OP b);
endprogram
module   leaf2m (oif.OP a[4], oif.OP b);
endmodule
program  leafAAp(oif.OP a[4], oif.OP c[4]);
endprogram
module   leafAAm(oif.OP a[4], oif.OP c[4]);
endmodule
program  leaf1Sp(oif.OP a[1]);
endprogram
module   leaf1Sm(oif.OP a[1]);
endmodule
program  leaf1Rp(oif.OP a[3:0]);
endprogram
module   leaf1Rm(oif.OP a[3:0]);
endmodule

module midy(oif.OP a[4], oif.OP b);
  leaf2p y2(a, b);
endmodule

module top();
bit Clock;
oif a[4](Clock);
oif b(Clock);
oif c2[4](Clock);
oif a1[1](Clock);

leaf2p  w1(.*);          // program, WILDCARD
leaf2m  w2(.*);          // module,  WILDCARD  (control)
leafAAp x1(a, c2);       // program, TWO array ports
leafAAm x2(a, c2);       // module,  TWO array ports (control)
midy    y1(a, b);        // program TWO levels down: top -> y1 -> y2
leaf1Sp z1(a1);           // program, [1] dimension
leaf1Sm z2(a1);           // module,  [1] dimension (control)
leaf1Rp z3(a);           // program, [3:0] dimension
leaf1Rm z4(a);           // module,  [3:0] dimension (control)
endmodule
