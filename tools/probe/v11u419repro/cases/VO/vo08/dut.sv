// § implicitPortParamListedFirst419
module m #(parameter A = 1, int B = 2, parameter type T = logic, bit C = 1) (input [A-1:0] x, output T y);
  assign y = T'(B + C);
endmodule
module top(input x, output logic y);
  m u(x, y);
endmodule
