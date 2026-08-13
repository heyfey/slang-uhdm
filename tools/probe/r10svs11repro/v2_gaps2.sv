// r10svs11 VERIFIER arm v2 — the branches where SHIP and PRIS can DIVERGE and
// the implementer's grid measured NOTHING.
//
// `mixed9` (pristine) is FALSE on an ALL-INTERFACE list, so pristine MINTS.
// `udpShapedInstantiation` (shipped) accepts ElementSelectExpression and
// MemberAccessExpression as net_lvalues, so shipped SKIPS.  These two cells are
// therefore SHIP != PRIS, and c1/c2/c3 contain neither: c2's element-select and
// member-access shapes are all MIXED lists (mixed9 true both ways).
interface ifa(input bit clk);
  logic sig;
  modport MP(input clk, output sig);
endinterface

module k2 (ifa.MP m, ifa.MP n);  logic q; endmodule

module top();
bit Clock;
ifa arr[4](Clock);
ifa x1(Clock);
ifa y1(Clock);
ifa y2(Clock);
ifa n1(Clock);
ifa n2(Clock);
// z1  ELEMENT-SELECT first terminal, ALL-INTERFACE ordered list
k2 z1 (arr[0], x1);
// z2  MEMBER-ACCESS (modport-qualified) first terminal, ALL-INTERFACE list
k2 z2 (y1.MP, y2);
// z3  control: the same child with a NAMED list
k2 z3 (.m(n1), .n(n2));
endmodule
