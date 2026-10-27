// § foreachLeadSkipPlaceholder439
module top;
int arr2[2][3];
for (genvar g = 0; g < 1; g++) begin : gb
  initial foreach (arr2[, j]) arr2[g][j] = j;
end
endmodule
