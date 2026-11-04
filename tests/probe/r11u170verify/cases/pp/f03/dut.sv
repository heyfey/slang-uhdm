// § pkgFoldLeftParenSpan158
package pk;
  localparam int A = 4;
  localparam int P = (-A) + 8;
  localparam int S = (A << 1) >> 1;
endpackage
module top (output logic [pk::P-1:0] o, output logic [pk::S-1:0] s); assign o = '0; assign s = '0; endmodule
