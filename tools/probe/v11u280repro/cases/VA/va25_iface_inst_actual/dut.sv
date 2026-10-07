// § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280 § hpMemVarSelNamesFinal280
// the path as an interface instance's port actual and a child port actual two levels down
interface ifc(input logic a); endinterface
module kid(input logic a, output logic o); assign o = a; endmodule
module mid(input logic [1:0] k, output logic o);
  typedef struct packed { logic [3:0][1:0] g; logic b; } s_t;
  s_t z;
  assign z = '0;
  ifc u_if (.a(z.g[k][1]));
  kid u_k (.a(z.g[k][0]), .o(o));
endmodule
module top(input logic [1:0] k, output logic o); mid u_m (.k(k), .o(o)); endmodule
