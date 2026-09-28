// § hiddenBlockVarMintNoFile207: hidden logic in a function body and in a nested named block, one assigned with a nonblocking assignment
module m (clk, in, q);
input clk, in;
output reg q;
function f;
input x;
begin : fb
logic t;
t = x;
f = t;
end
endfunction
always @(posedge clk) begin : outer
begin : inner
logic n;
n <= in;
q <= f(n);
end
end
endmodule
