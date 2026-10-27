// § progLocalDeclNets444
program prg;
logic [7:0] x;
initial begin
  logic [3:0] n;
  reg r;
  logic signed s;
  integer i;
  n = x[3:0];
  r = n[0];
  s = r;
  i = s;
end
endprogram
