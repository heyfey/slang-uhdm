// § progIfaceParamNoShadow445
module top; endmodule
program prg;
int arr[4]; int s;
parameter int i = 1;
initial foreach (arr[i]) s = s + i;
endprogram
