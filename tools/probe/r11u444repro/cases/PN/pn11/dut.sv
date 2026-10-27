// § progLocalDeclNets444
program prg;
logic [7:0] x;
task automatic t();
  logic [3:0] n;
  bit b;
  n = x[3:0];
  b = n[0];
endtask
initial t();
endprogram
