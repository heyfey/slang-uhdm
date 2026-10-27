// § foreachLeadSkipPlaceholder439
module top;
int arr2[2][3];
initial foreach (arr2[, j]) arr2[0][j] = j;
endmodule
