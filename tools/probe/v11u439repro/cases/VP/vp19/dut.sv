// § uninstProgBodyAsUninstIface439
program prg;
int x;
logic [3:0] v;
initial begin
  x = 1;
  assert (x == 1) else $error("bad");
  v = '0;
  v[1] = 1'b1;
  v[3:2] = 2'b10;
  x++;
  x += v;
end
endprogram
