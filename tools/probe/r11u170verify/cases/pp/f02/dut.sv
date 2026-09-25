// § pkgFoldLeftParenSpan158
package pk;
  localparam int A = 6;
  localparam int B = 3;
  localparam int P = (A > B ? A : B) + 1;
  localparam int Q = (int'(B)) - 1;
  localparam bit R = (A + 1) == 7;
endpackage
module top (output logic [pk::P-1:0] o, output logic [pk::Q:0] q, output logic r);
  assign o = '0; assign q = '0; assign r = pk::R;
endmodule
