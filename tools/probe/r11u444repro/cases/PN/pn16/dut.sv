// § progLocalDeclNets444
program prg;
int x;
task automatic t();
  int loc;
  loc = x;
endtask
int y;
initial t();
endprogram
