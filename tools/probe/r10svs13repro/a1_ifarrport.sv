// r10svs13 arm a1 — WHO CARRIES THE PER-INSTANCE interface_array?
//
// Axes, one cell per instantiation:
//   * PARENT KIND      program  vs  module_inst
//   * CONNECTION SHAPE ordered x2 (UDP-SHAPED per udpShapedInstantiation)
//                      ordered x1 (NOT udp-shaped: fewer than 2 terminals)
//                      named     (NOT udp-shaped: no OrderedPortConnection)
// The port under test is always a WHOLE interface ARRAY port (oif.OP a[4]),
// connected to the array instance `arr` as written.  The scalar companion port
// `b` is what makes the ordered list reach two terminals — the same shape the
// SVSwitch witness has (`testcase TC (mem_intf,input_intf,output_intf);`).
//
// The measurement is the elab instance's OWN vpiInterface / vpiInterfaceArray
// vectors, which program::Compare (generated program.cpp:215,217) and
// module_inst::Compare (module_inst.cpp:401,402) both read, Interfaces() first.
interface oif(input bit clock);
  logic [7:0] d;
  modport OP(input clock, output d);
endinterface

module leaf2m(oif.OP a[4], oif.OP b);
endmodule
program leaf2p(oif.OP a[4], oif.OP b);
endprogram
module leaf1m(oif.OP a[4]);
endmodule
program leaf1p(oif.OP a[4]);
endprogram

module top();
bit Clock;
oif arr[4](Clock);
oif sc(Clock);

leaf2p p1(arr, sc);
leaf2p p2(.a(arr), .b(sc));
leaf1p p3(arr);
leaf1p p4(.a(arr));
leaf2m m1(arr, sc);
leaf2m m2(.a(arr), .b(sc));
leaf1m m3(arr);
leaf1m m4(.a(arr));
endmodule
