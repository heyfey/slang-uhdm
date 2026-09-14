typedef enum logic [1:0] { A=0, B=1, C=2 } e_t;
module top(input logic [31:0] a, output e_t we);
  if (1) begin : gb
    assign we = '{default: '0};
  end
endmodule
