// § uninstProgIncDecBinds439v
program prg;
int garr[4];
int x;
initial begin
  int k;
  k = 1;
  garr[k]++;
  garr[k+1]--;
  x++;
  garr[x]++;
  if (x > 0) garr[k]++;
end
initial begin : nb2
  int m;
  garr[m]++;
end
endprogram
