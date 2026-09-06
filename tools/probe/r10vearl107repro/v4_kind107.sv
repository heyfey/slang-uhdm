// v107 adversarial arm v4 -- MEASUREMENT ONLY.
// MEMBER KIND faces: an ENUM member, a packed-ARRAY member, a NESTED struct
// member, a 64- and a 65-bit member, and a localparam-sourced value.
package pv4_107;
  typedef enum logic [2:0] { E0 = 0, E5 = 5 } e3_t;
  typedef struct packed { logic [3:0] n4; logic [1:0] n2; } inner_t;
  typedef struct packed {
    e3_t             en;
    logic [3:0][7:0] pa;
    inner_t          nst;
    logic [63:0]     x64;
  } k_t;
  parameter k_t P_K = '{ en: e3_t'('1), pa: '1, nst: '{ n4: '1, n2: '0 }, x64: '1 };
  parameter k_t P_K0 = '{ en: e3_t'('0), pa: '0, nst: '{ n4: '0, n2: '1 }, x64: '0 };

  typedef struct packed { logic [64:0] b65; logic [63:0] b64; } big_t;
  parameter big_t P_BIG = '{ b65: '1, b64: '1 };
  localparam big_t L_BIG = '{ b65: '0, b64: '1 };
endpackage

module chv4_107 (
  input pv4_107::k_t a, input pv4_107::k_t b,
  input pv4_107::big_t c, input pv4_107::big_t d
);
  logic u; assign u = ^{a,b,c,d};
endmodule

module v4_kind107 (input logic clk, output logic o);
  chv4_107 u_k (.a(pv4_107::P_K), .b(pv4_107::P_K0),
                .c(pv4_107::P_BIG), .d(pv4_107::L_BIG));
  assign o = clk;
endmodule
