module top(input logic [31:0] a, output logic [31:0] arr[2], output logic [1:0] we);
  assign arr = '{default: '0};
  assign we  = '{default: '0};
endmodule
