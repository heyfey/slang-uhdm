// § uninstIfaceIncDecBinds441
interface ifc;
int garr[2];
int x;
function void f2(int s); garr[s] = 1; x = garr[s]; s++; endfunction
endinterface
