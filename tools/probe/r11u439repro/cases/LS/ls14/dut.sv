// § foreachLeadSkipPlaceholder439
module top;
int arr2[2][3]; int b2[2][2];
initial foreach (arr2[, j]) foreach (b2[, k]) b2[0][k] = arr2[0][j];
endmodule
