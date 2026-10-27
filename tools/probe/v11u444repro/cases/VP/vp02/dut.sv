// § progLocalDeclNets444
program prg;
typedef logic [3:0] nib_t;
int x;
task automatic t();
  nib_t n;
  nib_t m [2];
  n = x[3:0];
  m[0] = n;
endtask
initial t();
endprogram
