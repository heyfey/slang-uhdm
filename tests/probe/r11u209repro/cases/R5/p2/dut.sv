// § ifacePortDeclTsAtPortDecl205: a non-ANSI interface output with a net-type keyword and a two-bound range
interface ifc (b);
  output wire [7:4] b;
  assign b = 4'd9;
endinterface
module top (output logic [3:0] y);
  ifc u (y);
endmodule
