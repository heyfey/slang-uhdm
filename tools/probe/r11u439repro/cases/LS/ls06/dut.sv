// § foreachTrailSkipDropped439
module top;
int arr3[2][3][4];
initial foreach (arr3[, j, ]) arr3[0][j][0] = j;
endmodule
