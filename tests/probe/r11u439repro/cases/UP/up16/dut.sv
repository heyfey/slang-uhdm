// § uninstProgBodyAsUninstIface439
program prg;
class C;
  int arr[3];
  function void f(); foreach (arr[i]) arr[i] = i; endfunction
endclass
initial begin C c = new; c.f(); end
endprogram
