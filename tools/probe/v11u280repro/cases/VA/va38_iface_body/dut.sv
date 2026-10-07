// § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280 § hpMemVarSelNamesFinal280
// an interface body reading its own struct variable with two selects, and an implicit net in the index
interface ifc(input logic [1:0] k);
  typedef struct packed { logic [3:0][1:0] g; logic b; } s_t;
  s_t z;
  logic o;
  assign z = '0;
  assign o = z.g[k][1];
endinterface
module top(input logic [1:0] k);
  ifc u (.k(k));
  assign imp = k[0];
endmodule
