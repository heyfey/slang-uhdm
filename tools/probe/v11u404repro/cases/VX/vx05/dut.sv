// § unitWideFillOnesBin404v
parameter logic [64:0] A = '1;
parameter bit [127:0] B = '1;
parameter logic signed [99:0] C = '1;
parameter logic [99:0] D = '0;
parameter logic [79:0] E = 'x;
module top;
  logic [127:0] a = B;
endmodule
