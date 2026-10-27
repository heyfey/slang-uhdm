// § foreachLeadSkipPlaceholder439
module top;
int a[2][3][4][5][6];
initial foreach (a[, , , l, ]) a[0][0][0][l][0] = l;
endmodule
