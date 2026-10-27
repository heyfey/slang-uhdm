// § progLocalDeclNets444
program prg;
int x;
task automatic t(input int a, output int b);
  int loc;
  loc = a * 2;
  b = loc + x;
endtask
initial t(1, x);
endprogram
