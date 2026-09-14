typedef struct packed { logic [1:0] x; logic y; } s_t;
module top(input logic [31:0] a, output s_t we2[2]);
  assign we2 = '{default: '0};
endmodule
