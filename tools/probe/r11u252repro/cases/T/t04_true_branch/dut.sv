// § lazyTernArithLeftSpan252
module top #(parameter X = 2, parameter Y = 1, localparam T = 1,
  localparam int A[2:0] = T ? '{X*Y+1, Y, 0} : '{Y+X, X, 0}) ();
endmodule
