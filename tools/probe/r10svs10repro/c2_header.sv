// r10svs10 arm c2 — HEADER FORM x ASSIGNMENT, the confound c1 exposed.
//
// c1 showed golden KEEPING the class-handle def-net ref_typespec in every
// scope, ASSIGNED or NOT — including a TOP module.  But OneThis (the golden the
// producer's `written` strip cites) DOES lose it, and OneThis's module is
// `module top(a, o); input a; output o;` — a NON-ANSI HEADER.  A SEPARATE rule
// already in the producer (`namedTypeNet`) strips the def-view typespec of any
// net whose type is a BARE identifier in a non-ANSI-header module.  So the
// question this arm settles is: does ASSIGNMENT do any work at all, or is the
// HEADER FORM carrying the whole load and the `written` strip a pure over-fire?
//
// Every header form appears twice — one ASSIGNED handle, one never assigned —
// so assignment is varied WITHIN each header form and cannot hide behind it.
package pk;
  class SK; int z; endclass
endpackage

class K;
  int x;
  function new(int v = 0); x = v; endfunction
endclass

typedef K K_t;

// ---- f: NO header at all ----
module f_none;
  K f1;                 // f1 no header,        ASSIGNED
  K f2;                 // f2 no header,        never assigned
  initial f1 = new();
endmodule

// ---- g: EMPTY PARENS header ----
module g_empty();
  K g1;                 // g1 empty parens,     ASSIGNED
  K g2;                 // g2 empty parens,     never assigned
  initial g1 = new();
endmodule

// ---- h: NON-ANSI port list (the OneThis shape) ----
module h_nonansi(a);
  input a;
  K h1;                 // h1 non-ANSI,         ASSIGNED
  K h2;                 // h2 non-ANSI,         never assigned
  initial h1 = new();
endmodule

// ---- i: ANSI header ----
module i_ansi(input logic a);
  K i1;                 // i1 ANSI,             ASSIGNED
  K i2;                 // i2 ANSI,             never assigned
  initial i1 = new();
endmodule

// ---- j: NON-ANSI, but the type NAME is not a bare identifier ----
module j_nonansi(a);
  input a;
  pk::SK j1;            // j1 non-ANSI, SCOPED name,   ASSIGNED
  pk::SK j2;            // j2 non-ANSI, SCOPED name,   never assigned
  K_t    j3;            // j3 non-ANSI, TYPEDEF'd name, ASSIGNED
  K_t    j4;            // j4 non-ANSI, TYPEDEF'd name, never assigned
  initial begin j1 = new(); j3 = new(); end
endmodule

// ---- k: NON-ANSI, WITH a declaration initializer (namedTypeNet declines) ----
module k_nonansi(a);
  input a;
  K k1 = new();         // k1 non-ANSI, decl-init      (an assignment, of a kind)
  K k2;                 // k2 non-ANSI, never assigned (control)
endmodule

module top_c2;
  f_none    u_f();
  g_empty   u_g();
  h_nonansi u_h(1'b0);
  i_ansi    u_i(1'b0);
  j_nonansi u_j(1'b0);
  k_nonansi u_k(1'b0);
endmodule
