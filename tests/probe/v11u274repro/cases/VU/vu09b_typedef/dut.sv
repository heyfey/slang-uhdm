// § pkgElabUnaryFoldOpSpan274
package pk;
  typedef logic signed [7:0] sb_t;
  parameter sb_t A = -3;
  typedef enum logic [1:0] {X0, X1, X2, X3} e_t;
  parameter logic [1:0] E = ~X1;
endpackage
module dut(output int o); assign o = 0; endmodule
