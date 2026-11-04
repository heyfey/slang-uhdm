// § ifFillArmSharesDefOperand309
module m #(parameter bit P = 0)(input logic sig, output logic [7:0] w);
  assign w = (P) ? {8{sig}} : '0;
endmodule
module top (input logic s, output logic [7:0] o);
  m u (.sig(s), .w(o));
endmodule
