// § foreachLeadSkipPlaceholder439
program prg;
int a[2][3];
initial foreach (a[, j]) a[0][j] = j;
endprogram
module top;
prg p();
endmodule
