// § foreachTrailSkipDropped439
module top;
int a[2][3][4];
initial foreach (a[i, j, ]) a[i][j][0] = i + j;
endmodule
