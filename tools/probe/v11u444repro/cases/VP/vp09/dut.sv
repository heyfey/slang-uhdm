// § progLocalDeclNets444
program prg;
int x;
task automatic t();
  enum {A, B} e;
  struct packed { logic a; logic [2:0] b; } s;
  e = B;
  s = 4'h3;
  x = s.b;
endtask
initial t();
endprogram
