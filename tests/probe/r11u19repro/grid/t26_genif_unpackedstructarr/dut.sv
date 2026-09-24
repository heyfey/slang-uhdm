typedef struct packed { logic [1:0] x; logic y; } s_t;
module top(input logic [31:0] a, output s_t we2[2]);
  if (1) begin : gb
    assign we2 = '{default: '0};
  end
endmodule
