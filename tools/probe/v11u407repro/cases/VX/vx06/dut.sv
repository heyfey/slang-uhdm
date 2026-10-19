// § typedParamXzLitSize407
module sub #(parameter logic [7:0] P = 4'hx, parameter int Q = 1'sbx) (output logic [7:0] o, output int q);
  assign o = P;
  assign q = Q;
endmodule
module top(output logic [7:0] o, output int q);
  sub u(o, q);
endmodule
