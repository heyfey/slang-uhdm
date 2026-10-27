// § progIfaceParamNoShadow445
module top; prg p(); endmodule
program prg;
int arr[4]; int s;
parameter type i = int;
initial foreach (arr[i]) s = s + 1;
endprogram
