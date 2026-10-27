// § uninstIfaceIncDecBinds441
interface ifc;
int garr[4];
function void f(int s);
  for (int i = 0; i < 4; i++) garr[i]++;
  for (s = 0; s < 4; s++) garr[s]--;
  foreach (garr[j]) garr[j]++;
endfunction
initial begin
  int k;
  for (k = 0; k < 2; ++k) ;
  do k--; while (k > 0);
  while (k < 3) k++;
end
endinterface
