// § progLocalDeclNets444
program prg;
int x;
task automatic t();
  int a, b;
  a = x; b = a;
endtask
initial t();
endprogram
