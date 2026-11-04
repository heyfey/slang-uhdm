// § progIfaceParamNoShadow445
module top; prg p(); endmodule
program prg;
int arr[4];
int s;
localparam logic [1:0] i = 1;
initial foreach (arr[i]) arr[i] = i;
endprogram
