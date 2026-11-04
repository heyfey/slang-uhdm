// § progLocalDeclNets444
program prg;
int x;
task automatic t();
  int x;
  begin int x; x = 2; end
  x = 1;
endtask
initial begin int x; x = 3; t(); end
endprogram
