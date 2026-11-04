// § loopVarParamReadUnbound445
module top;
localparam int item = 2;
int q[$]; int s; int r[$];
initial begin r = q.find_index with (item > 0); s = q.sum() with (item); end
endmodule
