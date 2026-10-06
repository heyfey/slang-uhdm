// § lazyTernArithLeftSpan252
module top #(parameter X = 2, parameter Y = 1) (output logic [31:0] o);
  localparam T = 0;
  localparam int A[1:0] = T ? '{X * Y, 1} : '{X + Y + 1, Y * 3};
  logic [A[1]-1:0] w;
  assign w = '1;
  assign o = {A[0]{1'b1}} + w;
endmodule
