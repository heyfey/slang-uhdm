// § foreachLoopVarShadowDeclTs445
module top;
int arr[4]; int s; logic clk, rst;
always_ff @(posedge clk) begin int i; if (rst) s <= 0; else foreach (arr[i]) s <= s + i; end
endmodule
