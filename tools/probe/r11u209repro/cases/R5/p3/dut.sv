// § ifacePortDeclTsAtPortDecl205: a signing keyword (declined by the law)
interface ifc (a);
  input signed [3:0] a;
  wire signed [3:0] a;
endinterface
module top (input logic signed [3:0] x);
  ifc u (x);
endmodule
