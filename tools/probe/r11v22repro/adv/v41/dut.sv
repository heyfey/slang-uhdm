typedef enum logic [2:0] { E0, E1, E2 } e_t;
module top(input logic [31:0] a, output e_t o);
  if (1) begin : gb
    assign o = (1) ? '1 : '0;
  end
endmodule
