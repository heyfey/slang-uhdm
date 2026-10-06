// § genEnumVarLocatedConst262 (explicit sized values, select positions and operands, gen-local enum var)
package ip;
  typedef enum logic [2:0] { S_A = 3'd1, S_B = 3'b011, S_C = 3'h5 } s_t;
endpackage
module wb import ip::*; #(parameter bit P = 1) (input logic clk, input s_t t_i, input logic [7:0] v_i, output logic [2:0] o);
  if (P) begin : g
    s_t q; logic [2:0] d;
    always_ff @(posedge clk) q <= t_i;
    assign d = v_i[S_C-:3] ^ {3{q == S_B}} ^ v_i[S_A];
    assign o = d;
  end
endmodule
module top(input logic clk, input ip::s_t t, input logic [7:0] v, output logic [2:0] o);
  wb u(.clk(clk), .t_i(t), .v_i(v), .o(o));
endmodule
