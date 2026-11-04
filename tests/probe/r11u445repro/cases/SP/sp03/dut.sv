// § progIfaceParamNoShadow445
module top; prg p(); endmodule
program prg;
int arr[4];
int s;
int i;
initial foreach (arr[i]) s = s + i;
endprogram
