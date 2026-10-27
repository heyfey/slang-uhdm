// § foreachLeadSkipPlaceholder439
module sub;
int a[2][3];
initial foreach (a[, j]) a[1][j] = j;
endmodule
module top;
sub u1();
sub u2();
endmodule
