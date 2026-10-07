// § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280
// rvalue interface instance member two selects (module instance path)
interface ifc;
  logic [3:0][1:0] sat;
endinterface
module top(input logic [1:0] s_i, output logic o);
  ifc m0();
  assign m0.sat = '0;
  assign o = m0.sat[s_i][1];
endmodule
