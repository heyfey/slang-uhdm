// § foreachLeadSkipPlaceholder439
module top;
int arr4[2][3][4][5];
initial foreach (arr4[, , , l]) arr4[0][0][0][l] = l;
endmodule
