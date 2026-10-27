// § elabIfaceLoopVarReadBinds443
interface ifc; int arr[4]; initial foreach (arr[i]) arr[i] = i; endinterface
module top; ifc u(); endmodule
