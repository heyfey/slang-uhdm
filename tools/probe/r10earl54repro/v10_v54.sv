module snk10_54 (input [7:0] a, output [7:0] o);
  assign o = ~a;
endmodule
module v10_v54 (input logic sel, input logic [7:0] d, output logic [7:0] q);
  logic [7:0] w1;
  snk10_54 u_amb (.a({sel ? pkC_54::PC :                   {4 {1'b0}}, 4'h1}), .o(w1));
  assign q = w1;
endmodule
