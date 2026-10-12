// § ifCaPlainLhsNoVarBind305
interface bif();
  wire sig;
  wire [7:0] w;
  assign w = {8{sig}} | '0;
endinterface
module top;
  bif b0();
  bif b1();
endmodule
