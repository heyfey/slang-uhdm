// § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280 § hpMemVarSelNamesFinal280
// a parameterized child instantiated twice reading the path (elaborated clones)
module kid #(parameter int P = 1)(input logic [1:0] k, output logic o);
  typedef struct packed { logic [3:0][1:0] g; logic b; } s_t;
  s_t z;
  assign z = '0;
  assign o = z.g[k][P];
endmodule
module top(input logic [1:0] k, output logic [1:0] o);
  kid #(.P(0)) u0 (.k(k), .o(o[0]));
  kid #(.P(1)) u1 (.k(k), .o(o[1]));
endmodule
