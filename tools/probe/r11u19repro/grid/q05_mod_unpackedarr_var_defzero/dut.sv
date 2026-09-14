module top(input logic [31:0] a, output logic [31:0] o);
  logic [31:0] arr[2];
  assign arr = '{default: '0};
  assign o = arr[0];
endmodule
