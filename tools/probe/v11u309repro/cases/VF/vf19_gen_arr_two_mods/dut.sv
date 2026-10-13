// § ifFillArmSharesDefOperand309
interface bif #(parameter bit P = 0, parameter int W = 8)();
  logic sig;
  logic [W-1:0] w;
  assign w = (P) ? {W{sig}} : '0;
endinterface
module mid #(parameter int W = 8);
  if (1) begin : g
    bif #(.W(W)) ba [2] ();
  end
endmodule
module top;
  mid #(.W(3)) m0();
  mid #(.W(9)) m1();
endmodule
