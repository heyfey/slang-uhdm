// § uninstIfaceIncDecBinds441
interface ifc;
int garr[4];
int x;
function int g(int a); return a; endfunction
function void f3(int s);
  x = garr[s]++;
  if (s > 0) garr[s]++;
  garr[g(s)]++;
  begin : nb
    int q;
    q++;
  end
endfunction
endinterface
