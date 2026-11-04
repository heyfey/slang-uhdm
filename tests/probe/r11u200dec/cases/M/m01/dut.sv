module m01 #(parameter N = 2, parameter W = 4) (
    input  logic [N-1:0]          a,
    input  logic [N-1:0] [W-1:0]  b,
    input  logic [N-1:0] [2:0]    c,
    output logic [1:0] [3:0]      d
);
  assign d = b;
endmodule
