// § foreachCgArrLoopVarRef437
module top(input a);
covergroup cg; coverpoint a; endgroup
cg one;
int arr[3];
initial foreach (arr[i]) arr[i] = i;
endmodule
