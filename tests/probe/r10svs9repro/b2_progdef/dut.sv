// r10svs9 arm b2 — the successor head, localized.  Arm b1 proved a class-typed
// net in an UNINSTANTIATED program already carries its
// `ref_typespec -> class_typespec` on our side, byte-identical to golden.  This
// arm varies the ONE thing SVSwitch's `program testcase(...)` has that b1's `p`
// did not: it is INSTANTIATED, and it has PORTS.
class K;
  int x;
endclass

// n1 an uninstantiated, port-less program (b1's shape, carried for contrast).
program p0;
  K k0;
endprogram

// n2 an INSTANTIATED program with NO ports.
program p1;
  K k1;
endprogram

// n3 an INSTANTIATED program WITH a plain port.
program p2(input bit c);
  K k2;
endprogram

interface ifc(input bit clock);
  logic sig;
  modport MP(input clock, output sig);
endinterface

// n4 an INSTANTIATED program with an INTERFACE-MODPORT port — SVSwitch's own
//    shape (`program testcase(mem_interface.MEM mem_intf, …)`).
program p3(ifc.MP mp);
  K k3;
endprogram

module top;
  bit clk = 0;
  ifc u_i(clk);
  p1 P1();
  p2 P2(clk);
  p3 P3(u_i.MP);
endmodule
