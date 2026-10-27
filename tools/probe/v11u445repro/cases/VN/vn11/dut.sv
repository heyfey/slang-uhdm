// § loopVarParamReadUnbound445
module top;
parameter int i = 2;
int arr[4]; int s; int b[4];
initial foreach (arr[i]) begin s = s + b[i]; $display("%0d", i); end
endmodule
