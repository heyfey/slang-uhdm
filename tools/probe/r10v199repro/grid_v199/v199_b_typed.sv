package vpb;
  typedef logic [3:0] nib_t;
  typedef enum logic [1:0] { E0, E1 } en_t;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } st_t;
  parameter int    B_INT  = 7;
  parameter string B_STR  = "hello";
  parameter nib_t  B_NIB  = 4'h5;
  parameter en_t   B_EN   = E1;
  parameter st_t   B_ST   = 8'hab;
  parameter bit [7:0] B_BIT = 8'h0f;
  parameter integer B_ITG  = 'h20;
  parameter logic [2:0] B_LOG = 'h3;
  parameter real   B_REAL = 2.5;
  localparam int   B_LINT = 4;
endpackage
import vpb::*;
module vb(input logic clk);
  logic q;
  always_ff @(posedge clk) q <= 1'b0;
endmodule
