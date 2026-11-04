// § progLocalDeclNets444
program prg;
int x;
task automatic t();
  bit [3:0] a [2][3];
  int q [$];
  int aa [string];
  int d [];
  a[0][0] = x;
  q.push_back(x);
endtask
initial t();
endprogram
