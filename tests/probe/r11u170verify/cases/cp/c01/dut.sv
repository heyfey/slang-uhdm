// § implNetBareParamElab160
module sub #(parameter logic [3:0] P = 4'hA, parameter int Q = 3) (output logic o);
  assign a = P, b = Q;
  assign o = a ^ b;
endmodule
module top (output logic o, output logic o2);
  sub u(.o(o));
  sub #(.P(4'h5)) u2(.o(o2));
endmodule
