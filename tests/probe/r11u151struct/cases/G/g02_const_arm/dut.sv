// G: a control: the taken arm names a CONSTANT-valued parameter (get_value
// reads it; no share).
module top(output int o);
  parameter int D = 2;
  localparam int A = 5;
  localparam int B = 6;
  parameter int R = (D == 2) ? A : B;
  assign o = R;
endmodule
