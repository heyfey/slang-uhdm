// G: the taken arm names an unpacked-array pattern parameter.
module top(output int o);
  parameter int D = 2;
  localparam int A[2] = '{1, 2};
  localparam int B[2] = '{3, 4};
  parameter int R[2] = (D == 2) ? A : B;
  assign o = R[0];
endmodule
