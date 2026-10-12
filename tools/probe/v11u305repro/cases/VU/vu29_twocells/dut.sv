// § ifCaPlainLhsNoVarBind305
interface bif();
  logic sig;
  logic [7:0] w, v;
  assign w = {8{sig}} | '0;
  assign v = w & '1;
endinterface
module top;
  bif b0();
  bif b1();
endmodule
