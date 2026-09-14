typedef struct packed { logic [7:0] x; logic [7:0] y; } st_t;
module top(input logic [31:0] a, output st_t o);
  if (1) begin : gb
    assign o = (1) ? '{x:8'd1, y:8'd2} : '0;
  end
endmodule
