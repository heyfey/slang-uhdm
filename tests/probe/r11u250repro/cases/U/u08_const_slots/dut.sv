// § modParamKwTdCopy250
typedef int ui_t;
package p;
  typedef byte pb_t;
endpackage
module top import p::*; #(parameter ui_t W = 4, parameter pb_t K = 2) (input logic [W-1:0] a, output logic [W-1:0] o, output logic [2*K-1:0] r);
  localparam ui_t H = W / 2;
  logic [W-1:0] m [K];
  assign o = a[W-1 -: W] ^ {W{1'b1}};
  assign r = {K{2'b10}};
  assign m[0] = a[H-1:0];
endmodule
