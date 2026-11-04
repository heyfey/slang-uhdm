// § uninstProgSubBodyAsUninstIface439
program prg;
int x, y;
task automatic t(input int a, output int b);
  int loc;
  loc = a + x;
  b = loc;
  if (a > 0) y = a;
endtask
initial t(1, x);
endprogram
