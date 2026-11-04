// § caUnsizedRhsClonePerInst193
package pk;
  typedef struct packed { logic [1:0] a; logic [1:0] b; } s_t;
endpackage
module m import pk::*; (input logic c, input s_t s, output logic [7:0] y);
  assign y[3:0] = c ? s : '0;
endmodule
module top import pk::*; (input logic c, input s_t s, output logic [7:0] y1);
  m u_a (.c(c), .s(s), .y(y1));
endmodule
