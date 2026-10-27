// § foreachLeadSkipPlaceholder439
interface ifc;
int arr2[2][3];
initial foreach (arr2[, j]) arr2[0][j] = j;
endinterface
module top; ifc u(); endmodule
