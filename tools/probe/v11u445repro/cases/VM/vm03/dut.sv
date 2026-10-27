// § foreachLoopVarModParamTs445
module top;
parameter int i = 2;
int arr[4]; int s;
if (1) begin : g
  initial foreach (arr[i]) s = s + i;
end
endmodule
