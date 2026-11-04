// § uninstProgSubBodyAsUninstIface439
program prg;
int q[$];
function automatic int sum();
  int s = 0;
  foreach (q[i]) s += q[i];
  sum = s;
endfunction
initial begin q.push_back(1); q.push_back(sum()); end
endprogram
