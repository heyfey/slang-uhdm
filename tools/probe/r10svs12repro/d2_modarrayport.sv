// r10svs12 arm d2 — THE MODULE (NON-INTERFACE) ARRAY twin of d1.
//
// emitModuleArray's port loop is shared: it runs for an interface array in both
// views AND for a MODULE array in the DEF view (`modElems == nullptr`).  So any
// change to the port's name/span/fullname policy lands on module arrays too,
// and BasicOh's `oh_dsync wr_sync[AW:0] (.dout(..), .clk(..), …)` — the witness
// the def-order re-key rule was written for — is a module array.  This arm is
// the blast-radius measurement for the module side, cell for cell against d1.
//
// The UDP-form early return (`!useInterfacePath && udpFormInstantiation`) means
// a module array with >=2 purely positional connections and no `#()` gets NO
// def-view module_array at all; m3 and m5/m6 hold that boundary fixed while the
// port policy moves around it.
module leaf1(input bit a);          logic q; endmodule
module leaf2(input bit a, input bit b); logic q; endmodule
module leaf3 #(parameter P = 0) (input bit a, input bit b); logic q; endmodule

module top();

bit Clock;
bit Rst;
bit [3:0] Vec;

// m1  POSITIONAL, 1 conn  (size<2 -> NOT udp-form -> def module_array exists)
leaf1 b1[4](Clock);
// m2  NAMED, 1 conn
leaf1 b2[4](.a(Clock));
// m3  POSITIONAL, 2 conns -> UDP-FORM -> expect NO def-view module_array
leaf2 b3[4](Clock, Rst);
// m4  NAMED, 2 conns
leaf2 b4[4](.a(Clock), .b(Rst));
// m5  POSITIONAL 2 conns under a 1-value `#()` (still delay2 -> udp-form)
leaf3 #(1) b5[4](Clock, Rst);
// m6  NAMED, 2 conns, REVERSED written order (the def-order re-key rule)
leaf2 b6[4](.b(Rst), .a(Clock));
// m7  SCALAR module instance, POSITIONAL — ref_module control
leaf1 c1(Clock);
// m8  SCALAR module instance, NAMED — ref_module control
leaf1 c2(.a(Clock));
// m9  POSITIONAL, 1 conn, ELEMENT-SELECT actual on a MODULE array: the cell the
//     new HighConn-fullname rule reaches on the module side (a module array is
//     the only container whose non-NamedValue actual keeps a HighConn today —
//     `ifaceArr` excludes the interface one, see d3 k3/k4)
leaf1 b7[4](Vec[0]);
// m10 NAMED, 1 conn, ELEMENT-SELECT actual: the emitSyntaxExpr/syntaxRefPrefix
//     branch, which the ordered form cannot reach (no NamedPortConnectionSyntax)
leaf1 b8[4](.a(Vec[0]));

endmodule
