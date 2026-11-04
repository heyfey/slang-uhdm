// § uninstIfaceAssertListing436
interface ifc(input clk, input a, input b);
sequence S;
  a ##1 b;
endsequence
property Q;
  @(posedge clk) S;
endproperty
A1: assert property (Q);
endinterface
