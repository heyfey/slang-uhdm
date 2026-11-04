// § ifCaPlainLhsNoVarBind305
interface bif();
  logic sig;
  logic [7:0] w;
  assign w = {8{sig}} | '0;
endinterface
module top;
  bif b0();
endmodule
