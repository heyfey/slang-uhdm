// § anonMemberTdLastWriter212 — verifier: a package-qualified typedef in an anonymous struct with a module-typedef in the same struct
package p;
  typedef struct packed { logic [1:0] a; } pk_t;
endpackage
module dut(input logic [4:0] d, output logic o);
  typedef struct packed { logic [2:0] c; } mt_t;
  struct packed { p::pk_t mp; mt_t mm; } w;
  always_comb w = d;
  assign o = w.mm.c[0] ^ w.mp.a[1];
endmodule
