// § progLocalDeclNets444
program prg;
int a;
task automatic t();
  int b;
  fork
    begin int c; c = b; end
    begin : nb int d; d = a; end
  join
endtask
int e;
initial begin int f; t(); end
int g;
endprogram
