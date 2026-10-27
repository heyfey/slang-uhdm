// § foreachLoopVarShadowDeclTs445
module sub;
int arr[4]; int s;
for (genvar g = 0; g < 2; g++) begin : gl
  initial begin int i; foreach (arr[i]) s = s + i; end
end
endmodule
module top; sub u(); endmodule
