// § foreachLoopVarShadowDeclTs445
module top;
int arr[4];
for (genvar g = 0; g < 2; g++) begin : gl
  initial begin int i; foreach (arr[i]) arr[i] = i; end
end
endmodule
