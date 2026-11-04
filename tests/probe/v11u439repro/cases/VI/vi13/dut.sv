// § uninstProgIncDecBinds439v
program prg;
int garr[4][4];
task automatic t(int s, int s2);
  int cnt;
  cnt++;
  garr[s][s2]++;
  fork garr[s][0]++; join
  repeat (2) garr[0][s2]++;
endtask
endprogram
