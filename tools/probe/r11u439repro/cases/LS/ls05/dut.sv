// § foreachLeadSkipPlaceholder439
module top;
int arr4[2][3][4][5];
initial foreach (arr4[, , k, m]) arr4[0][0][k][m] = k + m;
endmodule
