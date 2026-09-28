// § anonMemberTdLastWriter212 — verifier: an interface zi declares a variable of the typedef; a module aa writes it in an anonymous struct
typedef struct packed { logic [3:0] a; logic b; } in_t;
interface zi;
  in_t iv;
endinterface
module aa(input logic [4:0] d, output logic o);
  zi u();
  struct packed { in_t ma; } w;
  always_comb w = d;
  always_comb u.iv = d;
  assign o = w.ma.b;
endmodule
