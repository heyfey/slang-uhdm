// § progIfaceParamNoShadow445
module top; prg p(); endmodule
program prg;
int arr[4]; int s;
parameter int i = 1;
initial begin int i; foreach (arr[i]) s = s + i; end
endprogram
