// § uninstProgBodyAsUninstIface439
program prg;
int x, y;
event e;
initial begin
  -> e;
  @(e) x = 1;
  wait (x == 1) y = x;
  #5 y = 2;
  disable fork;
end
endprogram
