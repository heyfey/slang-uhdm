// § progLocalDeclNets444
program prg;
int x;
task automatic t1();
  int i;
  i = x;
endtask
task automatic t2();
  int i;
  i = x + 1;
endtask
initial begin t1(); t2(); end
endprogram
