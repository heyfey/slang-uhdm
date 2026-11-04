// § ifCaPlainLhsNoVarBind305
interface bif #(parameter bit P = 0)();
  logic sig;
  logic [7:0] w;
  assign w = (P) ? {8{sig}} : '0;
endinterface
module top;
  bif #(.P(0)) b0();
endmodule
