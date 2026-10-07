// § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280 § hpMemVarSelNamesFinal280
// a class handle path read in a module initial block and in a task of a class
package pk;
  class c; logic [7:0] value [4][4]; endclass
endpackage
module top(input int k, output logic [7:0] o);
  pk::c h;
  initial begin h = new; o = h.value[k][1]; end
endmodule
