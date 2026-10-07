// § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280 § hpMemVarSelNamesFinal280
// a package variable root, qualified and imported
package pk;
  typedef struct packed { logic [3:0][1:0] g; logic b; } s_t;
  s_t pz;
endpackage
module top(input logic [1:0] k, output logic o, output logic p);
  import pk::pz;
  assign o = pk::pz.g[k][1];
  assign p = pz.g[k][0];
endmodule
