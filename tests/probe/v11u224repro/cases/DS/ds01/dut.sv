// § strLitPpEscIdShift224
module top(input logic a, output logic y, output logic z, output logic [31:0] w);
  localparam string S = "a\nb` c"; assign y = a; assign z = ~a;
  assign w = S.len();
endmodule
