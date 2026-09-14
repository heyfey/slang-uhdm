module top(input logic [31:0] a, output struct packed { logic [1:0] x; logic y; } we);
  if (1) begin : gb
    assign we = '{default: '0};
  end
endmodule
