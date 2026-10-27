// § elabProgLoopVarReadBinds443
interface ifc; int arr[3]; endinterface
module top; ifc u(); prg p(u); endmodule
program prg(ifc bus);
int s;
initial foreach (bus.arr[i]) s = s + i;
endprogram
