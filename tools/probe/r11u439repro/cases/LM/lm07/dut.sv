// § loopVarReadBindsModuleDecl439
module top;
int i;
int arr[4];
for (genvar g = 0; g < 1; g++) begin : gb
  initial foreach (arr[i]) arr[i] = i + g;
end
endmodule
