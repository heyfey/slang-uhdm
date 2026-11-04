// § ifCaPlainLhsNoVarBind305
interface bif();
  logic sig;
  logic [7:0] w;
  assign w = sig ? '1 : '0;
endinterface
module top;
  bif b0();
  bif b1();
  bif b2();
endmodule
