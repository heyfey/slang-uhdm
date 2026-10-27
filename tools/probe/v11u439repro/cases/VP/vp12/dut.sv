// § uninstProgBodyAsUninstIface439
program prg;
class C;
  int v;
  function void set(int a); v = a; endfunction
endclass
C h;
int x;
initial begin h = new; h.set(3); x = h.v; end
endprogram
