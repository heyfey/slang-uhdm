module snk10_54 (input [7:0] a, output [7:0] o);
  assign o = ~a;
endmodule
module v10step1 (input logic sel, input logic [7:0] d, output logic [7:0] q);
  logic [7:0] w1, w2, w3;
  snk10_54 u_sp1 (.a({sel ? d[3:0] : {4 {1'b0}}, 4'h1}), .o(w1));
  snk10_54 u_sp2 (.a({sel ? d[3:0] : {4'd 4{1'b0}}, 4'h2}), .o(w2));
  snk10_54 u_sp3 (.a({sel ? d[3:0] : { 4 { 1'b1 } }, 4'h3}), .o(w3));
  assign q = w1 ^ w2 ^ w3;
endmodule
