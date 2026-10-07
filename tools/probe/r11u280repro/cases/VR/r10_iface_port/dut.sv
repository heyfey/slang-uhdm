// § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280
// rvalue interface port member two selects inside a child
interface ifc;
  logic [3:0][1:0] sat;
endinterface
module kid(ifc p, input logic [1:0] s, output logic o);
  assign o = p.sat[s][0];
endmodule
module top(input logic [1:0] s, output logic o);
  ifc m0();
  assign m0.sat = '0;
  kid u (.p(m0), .s(s), .o(o));
endmodule
