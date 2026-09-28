// § anonMemberTdLastWriter212 — r11u217 s06: $unit typedefs used as anonymous-struct members of PORTS (an ANSI input port of anonymous struct type) and of a net, in modules and a program, with a continuous assignment typed by the typedef declared AFTER the anonymous members
typedef struct packed { logic [1:0] a; logic b; } in_t;
module mb(input struct packed { in_t pm; } d, output logic o);
  assign o = d.pm.b;
endmodule
module ma(input logic [2:0] i, output logic o);
  wire struct packed { in_t nm; } n = i;
  in_t tail;
  assign tail = i;
  mb u (.d(n), .o(o));
endmodule
