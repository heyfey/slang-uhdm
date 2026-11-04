// § uninstProgSubBodyAsUninstIface439
program prg;
int x;
function static int f(input int a);
  static int cnt = 0;
  cnt = cnt + a;
  return cnt + x;
endfunction
task t(); x = f(2); endtask
initial t();
endprogram
