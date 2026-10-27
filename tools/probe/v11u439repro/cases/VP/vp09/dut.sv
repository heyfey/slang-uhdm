// § uninstProgBodyAsUninstIface439
program p1;
int a[2];
initial foreach (a[i]) a[i] = i;
endprogram
program p2;
int b[2];
initial foreach (b[j]) b[j] = j;
endprogram
module top;
p1 u1();
endmodule
