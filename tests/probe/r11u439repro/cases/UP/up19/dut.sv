// § uninstProgBodyAsUninstIface439
module top; prg p(); endmodule
program prg;
int arr[4];
initial foreach (arr[i]) arr[i] = i;
endprogram
