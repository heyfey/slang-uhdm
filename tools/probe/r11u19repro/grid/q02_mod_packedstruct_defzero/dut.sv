module top(input logic [31:0] a, output struct packed { logic [1:0] x; logic y; } we);
  assign we = '{default: '0};
endmodule
