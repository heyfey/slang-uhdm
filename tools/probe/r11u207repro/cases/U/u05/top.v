// § hiddenBlockVarMintNoFile207: hidden block variables inside a for-generate and an if-generate block, the module instantiated twice
module m (in);
parameter P = 1;
input in;
genvar i;
generate
for (i = 0; i < 2; i = i + 1) begin : g
  always @(posedge in) begin : blk
    logic h;
    h = in;
  end
end
if (P) begin : c
  always @(in) begin : b2
    logic k;
    k = in;
  end
end
endgenerate
endmodule
module top(input i); m #(1) u1(i); m #(0) u2(i); endmodule
