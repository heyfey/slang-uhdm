// § foreachLeadSkipPlaceholder439
module top;
int arr3[2][3][4];
initial foreach (arr3[i, , k]) arr3[i][0][k] = i + k;
endmodule
