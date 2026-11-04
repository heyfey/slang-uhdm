// § progLocalDeclNets444
program prg;
int x;
initial begin
  int b[3];
  b[0] = x;
end
task automatic t();
  int c[2][3];
  logic [3:0] d [4];
  int e[];
  c[0][0] = x;
  d[0] = 4'h1;
endtask
initial t();
endprogram
