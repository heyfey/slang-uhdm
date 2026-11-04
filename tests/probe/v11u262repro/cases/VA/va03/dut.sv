// § genEnumVarLocatedConst262 (a logic variable and an enum variable of another enum declared before the enum variable)
package ip;
  typedef enum logic [1:0] { E_A, E_B, E_C } e_t;
  typedef enum logic [1:0] { F_A, F_B } f_t;
endpackage
module wb import ip::*; #(parameter bit P = 1) (input logic clk, input e_t t_i, input logic v_i, output logic o);
  if (P) begin : g
    logic z;
    ip::f_t fq;
    e_t q;
    always_ff @(posedge clk) begin q <= t_i; fq <= ip::F_A; z <= v_i; end
    assign o = (q == E_B) | z | (fq == ip::F_B);
  end
endmodule
module top(input logic clk, input ip::e_t t, input logic v, output logic o);
  wb u(.clk(clk), .t_i(t), .v_i(v), .o(o));
endmodule
