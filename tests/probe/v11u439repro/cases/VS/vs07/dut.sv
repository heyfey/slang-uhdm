// § foreachLeadSkipPlaceholder439
module top;
int a[2][3];
initial foreach (a[i]) foreach (a[, j]) a[i][j] = i + j;
endmodule
