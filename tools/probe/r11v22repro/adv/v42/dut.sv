typedef struct packed { logic [7:0] x; logic [3:0] y; } st_t;
module top(input logic [31:0] a, output st_t o);
  if (1) begin : gb
    assign o = (1) ? '1 : '0;
  end
endmodule
