// § anonMemberTdOwnerDef212v — r11u217 s03: a header declaring a module-scope typedef included in a MODULE and in an INTERFACE (the interface has the anonymous member, the module a plain variable), both instantiated
interface ii;
`include "td.svh"
  struct packed { in_t mi; } w;
endinterface
module dut(input logic [4:0] d, output logic o);
`include "td.svh"
  in_t plain;
  ii u();
  assign plain = d;
  assign o = plain.b;
endmodule
