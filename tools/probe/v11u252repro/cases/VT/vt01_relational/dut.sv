// § lazyTernArithLeftSpan252
module top #(parameter X = 2, parameter Y = 1, localparam T = 0,
  localparam int A[2:0] = T ? '{X > Y, Y, 0} : '{Y == X, X - Y, (X)}) (output logic [31:0] o);
  assign o = A[0] + A[1] + A[2];
endmodule
