// § anonMemberTdOwnerDef212v — r11u217 s09: one header typedef included in a PROGRAM (anonymous member) and in a MODULE (a plain variable and a port of the typedef), the module name sorting before the program's
program zp;
`include "td.svh"
  struct packed { in_t pm; } w;
endprogram
module aa(input logic [4:0] d, output logic o);
`include "td.svh"
  in_t p;
  assign p = d;
  assign o = p.b;
endmodule
