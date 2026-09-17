// v7 — DOES A SELECT WRITTEN IN ANOTHER PACKAGE REDUCE THE DECLARING PACKAGE'S
// param_assign?  pc declares three identical unpacked-struct localparams and
// selects NONE of them.  pd (a different package) selects CFGX scoped and
// CFGY unqualified (imported); CFGN is never selected anywhere.  A module
// imports pc only, so its DEF copies are the measurement.
package pc;
  typedef struct { int unsigned a; int unsigned b; } c7_t;
  localparam c7_t CFGX = '{a: 1, b: 2};
  localparam c7_t CFGY = '{a: 3, b: 4};
  localparam c7_t CFGN = '{a: 5, b: 6};
endpackage

package pd;
  import pc::*;
  typedef logic [pc::CFGX.a-1:0] dx_t;   // SCOPED select of pc::CFGX, inside pd
  typedef logic [CFGY.a-1:0]     dy_t;   // UNQUALIFIED select of the import copy
  localparam int Q7 = 1;
endpackage

module v7q import pc::*; (input logic clk, output logic [7:0] d);
  assign d = '0;
endmodule

module v7d import pd::*; (input logic clk);
  dx_t x; dy_t y;
  assign x = '0; assign y = '0;
endmodule

module v7top(input logic clk);
  logic [7:0] dd;
  v7q u_q (.clk(clk), .d(dd));
  v7d u_d (.clk(clk));
endmodule
