// v11u79 q8 — THE TYPEDEF CHAIN LENGTH x THE TWO PACKAGE VIEWS.  q3 showed
// golden's two views DISAGREEING on a two-hop `bit` chain (def logic_net,
// elab bit_var) where a ONE-hop `bit` is bit_var in both.  The reading: the
// DEF view's signal carries the written type resolved exactly ONE hop, so a
// chain of two or more leaves `elabSignal` an alias typespec it has no arm
// for and the declaration's net answer stands; the ELABORATED view is fully
// resolved.  This arm spells every override kind at one, two and three hops.
package q8;
  typedef bit    [7:0]                            b1_t;
  typedef b1_t                                    b2_t;
  typedef b2_t                                    b3_t;
  b1_t                                            k_b1;
  b2_t                                            k_b2;
  b3_t                                            k_b3;
  typedef enum logic [1:0] { QA, QB }             e1_t;
  typedef e1_t                                    e2_t;
  e1_t                                            k_e1;
  e2_t                                            k_e2;
  typedef struct packed { int x; logic [7:0] y; } s1_t;
  typedef s1_t                                    s2_t;
  s1_t                                            k_s1;
  s2_t                                            k_s2;
  typedef struct packed { logic [7:0] a; logic [7:0] b; } g1_t;
  typedef g1_t                                    g2_t;
  g1_t                                            k_g1;
  g2_t                                            k_g2;
  typedef byte                                    y1_t;
  typedef y1_t                                    y2_t;
  y1_t                                            k_y1;
  y2_t                                            k_y2;
  typedef real                                    r1_t;
  typedef r1_t                                    r2_t;
  r1_t                                            k_r1;
  r2_t                                            k_r2;
  typedef struct { logic [7:0] a; byte b; }       u1_t;
  typedef u1_t                                    u2_t;
  u1_t                                            k_u1;
  u2_t                                            k_u2;
  typedef struct packed { logic [7:0] a; g1_t b; } n1_t;   // NESTED all-logic
  n1_t                                            k_n1;
  typedef struct packed { logic [7:0] a; s1_t b; } n2_t;   // NESTED with an int
  n2_t                                            k_n2;
  typedef struct packed { s1_t a; s1_t b; }        n3_t;   // BOTH members nested
  n3_t                                            k_n3;
  typedef struct { logic [7:0] a; u1_t b; }        n4_t;   // UNPACKED nested
  n4_t                                            k_n4;
endpackage

module dut (output logic [31:0] o);
  import q8::*;
  assign o = {24'd0, k_b1} ^ {24'd0, k_b2} ^ {24'd0, k_b3}
           ^ {30'd0, k_e1} ^ {30'd0, k_e2} ^ {16'd0, k_s1} ^ {16'd0, k_s2}
           ^ {16'd0, k_g1} ^ {16'd0, k_g2} ^ {24'd0, k_y1} ^ {24'd0, k_y2}
           ^ {8'd0, k_n1} ^ k_n2 ^ {24'd0, k_n3[7:0]};
endmodule
