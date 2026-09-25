// § sizeCastCaLitMask158
module sub #(parameter int W = 2) (output logic [7:0] p);
  assign p = 2'(W + 7);
endmodule
module dut (output logic [7:0] p, output logic [7:0] q);
  sub #(.W(1)) u1(.p(p));
  sub u2(.p(q));
endmodule
