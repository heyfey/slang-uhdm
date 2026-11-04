// § anonMemberTdOwnerDef212v — r11u217 s07: one header typedef included in THREE modules: ma and mz write it in anonymous structs (each its own member), mm only in a plain variable
module ma(input logic [4:0] d, output logic o);
`include "td.svh"
  struct packed { in_t ma_m; } w;
  assign w = d;
  assign o = w.ma_m.b;
endmodule
module mm(input logic [4:0] d, output logic o);
`include "td.svh"
  in_t p;
  assign p = d;
  assign o = p.b;
endmodule
module mz(input logic [4:0] d, output logic o);
`include "td.svh"
  struct packed { in_t mz_m; } w;
  assign w = d;
  assign o = w.mz_m.b;
endmodule
