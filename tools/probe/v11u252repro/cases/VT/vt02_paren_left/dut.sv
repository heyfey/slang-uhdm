// § lazyTernArithLeftSpan252
module top #(parameter X = 2, parameter Y = 1, localparam T = 1,
  localparam int A[2:0] = T ? '{(X + Y) * 2, -X + Y, X << 1} : '{0, 0, 0}) (output logic [31:0] o);
  assign o = A[0] + A[1] + A[2];
endmodule
