// § uninstProgBodyAsUninstIface439
program prg;
int arr[4];
int x;
initial begin
  fork
    x = 1;
    repeat (2) x = x + 1;
  join
  while (x < 10) x++;
  $display("%0d", x);
end
final $display("%0d", arr[0]);
endprogram
