// r10v99 ADVERSARIAL -- an ENUM-CONSTANT member value in a pattern reached by
// (a) the LANDED DIRECT carrier and (b) the NEW ternary carrier.
package pe99;
  typedef enum logic [5:0] { E0 = 6'd0, E1 = 6'd1, E7 = 6'd7 } e6_t;
  typedef struct packed { logic [3:0] w4; e6_t en; logic [7:0] w8; } s_t;
endpackage
module esub99 (input logic s, input logic [7:0] d, input pe99::s_t din,
               output pe99::s_t o_dir, output pe99::s_t o_ter);
  assign o_dir = '{ w4 : '1, en : pe99::E1, w8 : d };
  assign o_ter = s ? din : '{ w4 : '1, en : pe99::E1, w8 : '1 };
endmodule
module v99_enum (input logic s, input logic [7:0] d, input pe99::s_t din,
                 output pe99::s_t o_dir, output pe99::s_t o_ter);
  esub99 u (.s(s), .d(d), .din(din), .o_dir(o_dir), .o_ter(o_ter));
endmodule
