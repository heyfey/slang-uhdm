// § anonMemberTdOwnerDef212v — r11u217 s08: one header typedef included in an INTERFACE and a MODULE that BOTH write it in anonymous structs, the module instantiating the interface
interface ii;
`include "td.svh"
  struct packed { in_t im; } w;
endinterface
module dut(input logic [4:0] d, output logic o);
`include "td.svh"
  struct packed { in_t dm; } w;
  ii u();
  assign w = d;
  assign o = w.dm.b;
endmodule
