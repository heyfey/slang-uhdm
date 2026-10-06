// § lazyTernArithLeftSpan252
module top #(parameter X = 2, parameter Y = 1) ();
  localparam T = 0;
  localparam int A[2:0] = T ? '{X+Y, Y, 0} : '{(Y+X), X, 0};
endmodule
