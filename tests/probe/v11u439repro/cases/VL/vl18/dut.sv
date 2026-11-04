// § loopVarReadBindsModuleDecl439
program prg;
int i;
int arr[4];
initial foreach (arr[i]) arr[i] = i;
endprogram
module top;
prg p();
endmodule
