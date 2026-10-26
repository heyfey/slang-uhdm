// § foreachCgArrLoopVarRef437
module top(input a);
covergroup cg; coverpoint a; endgroup
cg cs[2];
int arr[2];
initial foreach (arr[i]) foreach (cs[j]) cs[j] = new;
endmodule
