// § aggParamFoldUnqualWholeSpan158
package pkg;
  typedef struct packed { logic [7:0] a; logic [7:0] b; } s_t;
  localparam s_t Y = 16'h1234;
  localparam s_t Z = '{a: 8'd1, b: 8'd2};
endpackage
module leaf #(parameter logic [7:0] V = 0)(); endmodule
module top(); import pkg::*; parameter s_t P = Y; logic [P.a-1:0] w; logic [P.b-1:0] x; endmodule
