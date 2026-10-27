// § progLocalDeclNets444
program prg;
int x;
task automatic t();
  for (int i = 0, j = 1; i < 2; i++) begin
    logic q;
    q = j[0];
  end
  foreach (x[k]) x[k] = 1'b0;
endtask
initial t();
endprogram
