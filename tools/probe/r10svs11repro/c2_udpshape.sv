// r10svs11 arm c2 — THE DECISIVE ARM: the CONNECTION-LIST SHAPE.
//
// Surelog's parser resolves `foo f(a, b);` — an ORDERED list of two or more
// terminals whose FIRST parses as a `net_lvalue` — as a **udp_instantiation**,
// not a module_instantiation (the law our own `udpShapedInstantiation` in
// src/EmitHelpers.h already states, decoded for `ref_module`).  This arm asks
// whether the SAME parse decides the CONNECTION-SITE NET for an interface
// actual, and crosses the shape against the axes that the SVSwitch witness
// (`testcase TC (mem_intf,input_intf,output_intf);`) confounds:
//
//   count of ordered terminals : 1 / 2 / 3
//   FIRST terminal's syntax    : net_lvalue (identifier) / operation / literal
//   other ports                : all-interface / mixed with regular ports
//   list kind                  : ordered / named / ordered-with-empty-terminal
//   #() override               : absent / 2 ordered values (still delay2)
//                                / 3 ordered values (exceeds delay2)
//
// Every interface instance is connected to EXACTLY ONE child, so the
// "connected to MULTIPLE children" clause of the producer cannot confound any
// cell.  Cell value = does work@top list a logic_net of that instance's name.
interface ifa(input bit clk);
  logic sig;
  modport MP(input clk, output sig);
endinterface

module k1 (ifa.MP m);                              logic q; endmodule
module k2 (ifa.MP m, ifa.MP n);                    logic q; endmodule
module k3 (ifa.MP m, ifa.MP n, ifa.MP o);          logic q; endmodule
module kmi(ifa.MP m, input logic a);               logic q; endmodule
module kim(input logic a, ifa.MP m);               logic q; endmodule
module kie(input logic a, input logic b, ifa.MP m); logic q; endmodule
module kp #(parameter int P1 = 0, parameter int P2 = 0, parameter int P3 = 0)
          (ifa.MP m, input logic a);               logic q; endmodule

module top();

bit Clock;

ifa e1i(Clock);
ifa e2a(Clock);  ifa e2b(Clock);
ifa e3a(Clock);  ifa e3b(Clock);  ifa e3c(Clock);
ifa e4i(Clock);
ifa e5i(Clock);
ifa e6i(Clock);
ifa e7i(Clock);
ifa e8i(Clock);
ifa e9a(Clock);  ifa e9b(Clock);
ifa e10i(Clock);
ifa e11i(Clock);
ifa e12i(Clock);
ifa e13i(Clock);
ifa e14i(Clock);

// e1  1 ordered terminal, all-interface            -> NOT udp-shaped
k1  u1  (e1i);
// e2  2 ordered terminals, both interface          -> UDP-SHAPED
k2  u2  (e2a, e2b);
// e3  3 ordered terminals, all interface           -> UDP-SHAPED
k3  u3  (e3a, e3b, e3c);
// e4  2 ordered, interface FIRST then regular      -> UDP-SHAPED
kmi u4  (e4i, Clock);
// e5  2 ordered, regular identifier FIRST          -> UDP-SHAPED (still a net_lvalue)
kim u5  (Clock, e5i);
// e6  2 ordered, OPERATION first                   -> NOT udp-shaped
kim u6  (Clock & 1'b1, e6i);
// e7  2 ordered, LITERAL first                     -> NOT udp-shaped
kim u7  (1'b0, e7i);
// e8  1 ordered terminal, child has a SECOND (regular) port left unconnected
kmi u8  (e8i);
// e9  2 NAMED connections, both interface          -> NOT udp-shaped
k2  u9  (.m(e9a), .n(e9b));
// e10 1 NAMED connection                           -> NOT udp-shaped
k1  u10 (.m(e10i));
// e11 2 ordered, interface first, OPERATION second -> UDP-SHAPED (first is what counts)
kmi u11 (e11i, Clock & 1'b1);
// e12 3 ordered with an EMPTY terminal             -> NOT udp-shaped
kie u12 (Clock, , e12i);
// e13 #(1,2) override: still reads as delay2       -> UDP-SHAPED
kp #(1,2) u13 (e13i, Clock);
// e14 #(1,2,3) override: exceeds delay2            -> NOT udp-shaped
kp #(1,2,3) u14 (e14i, Clock);

endmodule
