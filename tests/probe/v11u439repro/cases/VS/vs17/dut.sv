// § foreachLeadSkipPlaceholder439
module top;
int a[2][3];
initial foreach (a[, j]) foreach (a[, k]) a[0][j] = k;
endmodule
