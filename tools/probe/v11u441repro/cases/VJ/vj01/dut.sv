// § uninstIfaceIncDecBinds441
interface ifc;
  int garr[4];
  int cnt;
  initial begin
    int k;
    k++;
    garr[k]++;
    cnt++;
  end
endinterface
