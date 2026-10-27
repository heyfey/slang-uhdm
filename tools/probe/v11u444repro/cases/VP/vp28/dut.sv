// § progLocalDeclNets444
package pk;
  typedef logic [3:0] n_t;
  int pv;
endpackage
program prg;
import pk::*;
task automatic t();
  n_t a;
  pk::n_t b;
  a = pv[3:0];
  b = a;
endtask
int z;
initial t();
endprogram
