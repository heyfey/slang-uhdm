// § genEnumVarLocatedConst262 (case-generate, gen-local enum var, ternary branch values)
package ip;
  typedef enum logic [1:0] { E_A, E_B, E_C } e_t;
  typedef enum logic [2:0] { F_A, F_B, F_C, F_D } f_t;
endpackage
module wb import ip::*; #(parameter int P = 1) (input logic clk, input e_t t_i, input logic v_i, output e_t o);
  case (P)
    1: begin : g
      e_t q; e_t d;
      always_ff @(posedge clk) q <= t_i;
      assign d = v_i ? E_B : (q == E_A ? E_C : q);
      assign o = d;
    end
    default: begin : gd
      assign o = t_i;
    end
  endcase
endmodule
module top(input logic clk, input ip::e_t t, input logic v, output ip::e_t o);
  wb u(.clk(clk), .t_i(t), .v_i(v), .o(o));
endmodule
