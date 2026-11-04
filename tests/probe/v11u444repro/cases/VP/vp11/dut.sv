// § progLocalDeclNets444
program prg;
int x;
task automatic t();
  int unsigned u;
  bit [7:0] b;
  integer k;
  logic signed [3:0] ls;
  reg signed [3:0] rs;
  u = x; b = x; k = x; ls = x; rs = x;
endtask
initial t();
endprogram
