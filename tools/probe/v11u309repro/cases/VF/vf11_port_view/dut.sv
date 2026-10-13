// § ifFillArmSharesDefOperand309
interface bif #(parameter bit P = 0)();
  logic sig;
  logic [7:0] w;
  assign w = (P) ? {8{sig}} : '1;
  modport mp (input w);
endinterface
module child (bif.mp p, output logic o);
  assign o = p.w[0];
endmodule
module top (output logic o);
  bif b0();
  child c (.p(b0), .o(o));
endmodule
