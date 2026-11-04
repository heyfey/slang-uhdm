// § progIfaceParamNoShadow445
module top; prg #(.i(2)) p(); endmodule
program prg #(parameter int i = 1);
int arr[4]; int s;
initial foreach (arr[i]) s = s + i;
endprogram
