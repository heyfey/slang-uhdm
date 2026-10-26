// § uninstIfaceAssertListing436
interface ifc(input clk, input a, input b);
property P; @(posedge clk) a |-> b; endproperty
endinterface
