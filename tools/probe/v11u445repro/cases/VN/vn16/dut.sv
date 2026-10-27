// § loopVarParamReadUnbound445
module sub(input int p); endmodule
module top;
parameter int i = 2;
int arr[4]; int s;
sub u(.p(i));
initial foreach (arr[i]) s = s + i;
endmodule
