// § progLocalDeclNets444
program prg;
int x;
task automatic t();
  for (int k = 0; k < 2; k++) x = k;
endtask
initial begin
  for (int j = 0; j < 2; j++) x = j;
end
endprogram
