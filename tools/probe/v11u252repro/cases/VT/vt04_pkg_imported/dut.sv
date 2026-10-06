// § lazyTernArithLeftSpan252
package p;
  localparam X = 3;
  localparam T = 1;
  localparam int A[1:0] = T ? '{X + 1, X % 2} : '{0, 0};
endpackage
module top import p::*; #(parameter Q = 1) (output logic [31:0] o);
  assign o = A[0] + A[1];
endmodule
