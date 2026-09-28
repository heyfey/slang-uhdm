// § anonMemberTdOwnerDef212v — r11u217 s04: a MULTI-LINE MACRO declaring a module-scope typedef, invoked in two modules; module ma writes it in an anonymous struct, module mz declares only a plain variable of it
`define DECL \
  typedef struct packed { \
    logic [3:0] a; \
    logic b; \
  } in_t;
module ma(input logic [4:0] d, output logic o);
  `DECL
  struct packed { in_t mm; } w;
  assign w = d;
  assign o = w.mm.b;
endmodule
module mz(input logic [4:0] d, output logic o);
  `DECL
  in_t late;
  assign late = d;
  assign o = late.b;
endmodule
