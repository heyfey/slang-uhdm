// § uninstIfaceAssertListing436
interface ifc(input clk, input a, input b);
sequence S; @(posedge clk) a ##[1:3] b; endsequence
A1: assert property (S);
C2: cover sequence (S);
endinterface
