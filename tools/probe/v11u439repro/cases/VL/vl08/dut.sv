// § loopVarReadBindsModuleDecl439
interface bus; logic v; endinterface
module m(bus i);
int arr[4];
initial foreach (arr[i]) arr[i] = 1;
endmodule
module top;
bus b();
m u(.i(b));
endmodule
