// § progLocalDeclNets444
program prg;
typedef int d_t[];
typedef int a_t[2];
typedef int s_t[string];
task automatic t();
  d_t d;
  a_t a;
  s_t s;
  a[0] = 1;
endtask
initial t();
endprogram
