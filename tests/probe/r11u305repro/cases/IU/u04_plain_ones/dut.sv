// § ifCaPlainLhsNoVarBind305
interface bif #(parameter bit P = 0)();
  logic sig;
  logic [7:0] w;
  assign w = (P) ? {8{sig}} : '1;
endinterface
module top;
  bif b0();
  bif b1();
endmodule
