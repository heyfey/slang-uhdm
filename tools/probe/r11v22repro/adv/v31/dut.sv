typedef struct packed { logic [7:0] x; logic [7:0] y; } st_t;
module top(input logic [31:0] a, output logic [31:0] o);
  if (1) begin : gb
    assign o = ($bits(st_t) == 16) ? 32'd7 : '0;
  end
endmodule
