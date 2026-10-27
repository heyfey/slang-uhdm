// § foreachLeadSkipPlaceholder439
module top;
int d[][3];
initial begin d = new[2]; foreach (d[, j]) d[0][j] = j; end
endmodule
