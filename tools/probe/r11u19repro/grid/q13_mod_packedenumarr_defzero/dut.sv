typedef enum logic [1:0] { A=0, B=1, C=2 } e_t;
module top(input logic [31:0] a, output e_t [1:0] we);
  assign we = '{default: '0};
endmodule
