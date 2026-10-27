// § foreachLoopVarModParamTs445
module top;
parameter int i = 2;
int arr[4]; int s;
for (genvar g = 0; g < 2; g++) begin : gl
  initial foreach (arr[i]) s = s + i;
end
endmodule
