// § anonMemberTdLastWriter212 — r11u217 s01: a $unit struct typedef written as an anonymous-struct member in a PROGRAM, an INTERFACE and a MODULE, whose names sort in the reverse of the kind order (program zp, interface mi, module aa)
typedef struct packed { logic [3:0] a; logic b; } in_t;
program zp;
  struct packed { in_t mp; } w;
endprogram
interface mi;
  struct packed { in_t mi_m; } w;
endinterface
module aa(input logic [4:0] d, output logic o);
  struct packed { in_t ma; } w;
  mi i();
  assign w = d;
  assign o = w.ma.b;
endmodule
