// § foreachLeadSkipPlaceholder439
module top;
int arr3[2][3][4];
initial foreach (arr3[, , k]) arr3[0][0][k] = k;
endmodule
