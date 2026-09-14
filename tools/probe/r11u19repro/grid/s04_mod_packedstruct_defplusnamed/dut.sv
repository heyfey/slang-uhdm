typedef struct packed { logic [1:0] x; logic y; } s_t;
module top(input logic [31:0] a, output s_t we);
  assign we = '{default: '0, y: 1'b1};
endmodule
