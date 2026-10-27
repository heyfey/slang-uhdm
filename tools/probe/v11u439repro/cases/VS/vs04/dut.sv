// § foreachLeadSkipPlaceholder439
module top;
int a[2][3][4];
initial foreach (a[, j, ]) a[0][j][0] = j;
endmodule
