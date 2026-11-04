// § uninstIfaceIncDecBinds441
interface ifc;
int garr[2];
task t(int s); fork garr[s]++; join ++s; repeat (2) s++; endtask
endinterface
