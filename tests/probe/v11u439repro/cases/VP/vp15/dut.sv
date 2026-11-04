// § uninstProgSubBodyAsUninstIface439
program prg;
int arr[4];
function automatic void clr(); foreach (arr[n]) arr[n] = 0; endfunction
task automatic tick(); #1; arr[0] = arr[1]; endtask
initial begin clr(); tick(); end
endprogram
