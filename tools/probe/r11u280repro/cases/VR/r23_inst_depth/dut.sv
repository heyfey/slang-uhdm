// § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280
// rvalue member two selects at instance depths 1 to 3
module leaf(input logic [1:0] k, output logic o);
  typedef struct packed { logic [3:0][1:0] g; logic b; } s_t;
  s_t z;
  assign z = '0;
  assign o = z.g[k][1];
endmodule
module mid(input logic [1:0] k, output logic o);
  leaf u2 (.k(k), .o(o));
endmodule
module top(input logic [1:0] k, output logic o, output logic q);
  mid u1 (.k(k), .o(o));
  leaf u0 (.k(k), .o(q));
endmodule
