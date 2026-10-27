// § foreachTrailSkipDropped439
program prg;
int a[2][3][4];
initial foreach (a[i, , ]) a[i][0][0] = i;
endprogram
