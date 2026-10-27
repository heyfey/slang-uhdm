// § progLocalDeclNets444
program prg;
typedef int q_t[$];
int x;
task automatic t();
  q_t r;
  r.push_back(x);
endtask
initial t();
endprogram
