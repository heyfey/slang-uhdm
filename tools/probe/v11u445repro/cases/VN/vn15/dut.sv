// § loopVarParamReadUnbound445
module top;
parameter int i = 2;
int arr[4]; int s; logic clk; int y;
assign y = i;
always_ff @(posedge clk) foreach (arr[i]) s <= s + i;
endmodule
