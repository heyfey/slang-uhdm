// § uninstProgIncDecBinds439v
program prg;
int garr[4];
int x;
function int g(int a); return a; endfunction
function void f(int s, int s2);
  int la[4];
  garr[s+1]--;
  la[s]++;
  ++garr[s2];
  x = garr[s]++;
  if (x > 0) garr[s]++;
  garr[g(s)]++;
  begin garr[s2]++; end
  begin : nb garr[s]++; end
endfunction
endprogram
