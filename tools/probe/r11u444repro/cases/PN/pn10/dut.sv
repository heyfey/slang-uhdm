// § progLocalDeclNets444
program prg;
int x;
task automatic t();
  int x;
  x = 1;
endtask
initial t();
endprogram
