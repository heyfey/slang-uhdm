// § foreachTrailSkipDropped439
module top;
int arr3[2][3][4];
initial foreach (arr3[i, , ]) arr3[i][0][0] = i;
endmodule
