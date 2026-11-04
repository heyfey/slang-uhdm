// § uninstIfaceIncDecBinds441
interface ifc #(parameter int N = 4);
  int garr[N];
  task t(int s);
    int loc;
    loc--;
    garr[s]++;
    foreach (garr[j]) garr[j]++;
  endtask
endinterface
