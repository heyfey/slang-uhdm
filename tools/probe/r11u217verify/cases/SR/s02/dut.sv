// § anonMemberTdLastWriter212 — r11u217 s02: an anonymous UNION with a named ENUM typedef member and an anonymous struct nested in an anonymous struct, in two modules whose names sort `Zb` (upper case) before `ab`
typedef enum logic [1:0] { A, B, C } e_t;
typedef struct packed { logic [1:0] a; } in_t;
module ab(input logic [3:0] d, output logic o);
  union packed { e_t ue; logic [1:0] r; } u;
  struct packed { struct packed { in_t deep; } mid; logic [1:0] pad; } w;
  assign u = d[1:0];
  assign w = d;
  assign o = u.ue == B;
endmodule
module Zb(input logic [3:0] d, output logic o);
  union packed { e_t ze; logic [1:0] r; } u;
  struct packed { struct packed { in_t zdeep; } mid; logic [1:0] pad; } w;
  assign u = d[1:0];
  assign w = d;
  assign o = u.ze == C;
endmodule
