// § lazyTernArithLeftSpan252
module top #(parameter X = 2, parameter Y = 1, localparam T = 0, localparam U = 1,
  localparam int A[1:0] = T ? '{X, Y} : U ? '{Y+X, X} : '{0, 0}) ();
endmodule
