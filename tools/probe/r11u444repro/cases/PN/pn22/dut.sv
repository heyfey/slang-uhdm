// § progLocalDeclNets444
program prg;
logic [7:0] x;
task automatic t();
  reg [1:0] r;
  var logic v;
  logic l;
  r = x[1:0];
  v = r[0];
  l = v;
endtask
initial t();
endprogram
