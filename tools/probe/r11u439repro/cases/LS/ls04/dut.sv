// § foreachLeadSkipPlaceholder439
module top;
int arr3[2][3][4];
initial foreach (arr3[, j, k]) arr3[0][j][k] = j + k;
endmodule
