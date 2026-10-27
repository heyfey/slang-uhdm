// § progIfaceParamNoShadow445
module top; prg p(); endmodule
program prg;
int arr[4]; int s;
parameter int i = 1;
task automatic t; foreach (arr[i]) s = s + i; endtask
initial t();
endprogram
