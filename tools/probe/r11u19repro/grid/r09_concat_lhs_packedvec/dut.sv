module top(input logic [31:0] a, output logic [1:0] x, output logic [1:0] y);
  assign {x, y} = '{default: '0};
endmodule
