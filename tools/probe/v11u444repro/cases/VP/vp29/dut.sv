// § progLocalDeclNets444
program prg;
parameter int N = 3;
localparam int M = N + 1;
task automatic t();
  logic [N-1:0] a [M];
  int k;
  k = M;
  a[0] = k;
endtask
initial t();
endprogram
