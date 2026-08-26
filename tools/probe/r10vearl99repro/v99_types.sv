// r10v99 ADVERSARIAL -- packed and unpacked structs, packed and unpacked
// arrays, a union, a struct of structs; all through a ternary arm.
package pt99;
  typedef struct packed { logic [2:0] a3; logic [4:0] b5; } sp_t;
  typedef struct        { logic [2:0] a3; logic [4:0] b5; } su_t;
  typedef union  packed { logic [7:0] u8; sp_t us; } un_t;
  typedef struct packed { sp_t s1; sp_t s2; } ss_t;
  typedef logic [3:0] pa_t [0:3];
endpackage
module v99_types (input logic s,
                  output pt99::sp_t o_sp,
                  output pt99::un_t o_un,
                  output pt99::ss_t o_ss,
                  output logic [3:0][7:0] o_pa);
  pt99::su_t v_su;
  pt99::pa_t v_ua;
  assign o_sp = s ? '{ a3 : '1, b5 : '0 } : '{ a3 : 3'd1, b5 : 5'd1 };
  assign o_un = s ? '1 : 8'h01;
  assign o_ss = s ? '{ s1 : '{ a3 : '1, b5 : '0 }, s2 : '{ a3 : '0, b5 : '1 } }
                  : '{ s1 : '{ a3 : 3'd1, b5 : 5'd1 }, s2 : '{ a3 : 3'd2, b5 : 5'd2 } };
  assign o_pa = s ? '{ '1, '0, '1, '0 } : '{ 8'h1, 8'h2, 8'h3, 8'h4 };
  always_comb v_su = s ? '{ a3 : '1, b5 : '0 } : '{ a3 : 3'd1, b5 : 5'd1 };
  always_comb v_ua = s ? '{ '1, '0, '1, '0 } : '{ 4'h1, 4'h2, 4'h3, 4'h4 };
endmodule
