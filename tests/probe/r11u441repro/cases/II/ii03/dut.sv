// § uninstIfaceIncDecBinds441
interface ifc;
int garr[4];
int cnt;
task t1(int s);
  int loc;
  garr[s+1]--;
  loc++;
  cnt++;
  begin
    int k;
    garr[k]++;
  end
endtask
endinterface
