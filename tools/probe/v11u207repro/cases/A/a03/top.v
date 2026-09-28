// § hiddenBlockVarMintNoFile207: hidden logic declared with a width and an initial block, the variable used in an if condition and a case expression
module m (in, out);
input [3:0] in;
output reg out;
initial begin : ib
logic [3:0] w;
w = in;
if (w == 4'd2) out = 1'b1;
case (w)
  4'd1: out = 1'b0;
  default: out = 1'bx;
endcase
end
endmodule
