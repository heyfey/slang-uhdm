// § progLocalDeclNets444
program prg;
typedef int my_t;
int x;
task automatic t();
  my_t a = 5;
  my_t b [2];
  a = x;
endtask
initial t();
endprogram
