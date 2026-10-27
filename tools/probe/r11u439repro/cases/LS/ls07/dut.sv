// § foreachLeadSkipPlaceholder439
module top;
int arr4[2][3][4][5];
initial foreach (arr4[, j, , m]) arr4[0][j][0][m] = j + m;
endmodule
