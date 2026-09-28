// § ifacePortDeclTsAtPortDecl205: a port declaration spread across lines with a comment
interface ifc (o);
  output
    wire /* w */ [7:0]
    o;
  assign o = 8'h11;
endinterface
module top(output logic [7:0] y);
  ifc i (.o(y));
endmodule
