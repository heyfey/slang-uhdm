// r10v99 ADVERSARIAL -- member widths 1/4/32/64/65/128, a parameterized width,
// a width from an instance override, signed members, typedef- and enum-typed
// members; every one inside a cont_assign ternary arm.
package pw99;
  typedef logic [11:0] td12_t;
  typedef enum logic [5:0] { E0 = 6'd0, E1 = 6'd1 } e6_t;
  typedef struct packed {
    logic          w1;
    logic [3:0]    w4;
    logic [31:0]   w32;
    logic [63:0]   w64;
    logic [64:0]   w65;
    td12_t         wtd;
    e6_t           wen;
    logic signed [7:0] ws8;
  } wide_t;
  typedef struct packed { logic [127:0] a128; logic [7:0] b8; } h2_t;
endpackage

module sub99 #(parameter int W = 8) (input logic s, output logic [W+3:0] o);
  typedef struct packed { logic [W-1:0] pw; logic [3:0] q4; } pw_t;
  pw_t r;
  assign r = s ? '{ pw : '1, q4 : '0 } : '{ pw : '0, q4 : '1 };
  assign o = r;
endmodule

module v99_width (input logic s, output pw99::wide_t o1, output pw99::h2_t o2,
                  output logic [11:0] o3, output logic [35:0] o4);
  assign o1 = s ? '{ w1:'1, w4:'1, w32:'1, w64:'1, w65:'1, wtd:'1, wen:pw99::E1, ws8:'1 }
                : '{ w1:'0, w4:'0, w32:'0, w64:'0, w65:'0, wtd:'0, wen:pw99::E0, ws8:'0 };
  assign o2 = s ? '{ a128 : '1, b8 : '1 } : '{ a128 : '0, b8 : '0 };
  sub99 #(.W(8))  u_a (.s(s), .o(o3));
  sub99 #(.W(32)) u_b (.s(s), .o(o4));
endmodule
