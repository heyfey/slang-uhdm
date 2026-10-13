// § ifFillArmSharesDefOperand309
interface bif #(parameter bit P = 0, parameter int W = 8)();
  logic sig;
  logic [W-1:0] w;
  assign w = (P) ? {W{sig}} : '0;
endinterface
module top;
  for (genvar i = 0; i < 2; i++) begin : g
    bif b ();
  end
endmodule
