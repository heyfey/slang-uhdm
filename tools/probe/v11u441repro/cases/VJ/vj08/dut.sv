// § uninstIfaceIncDecBinds441
interface ifc;
  logic clk;
  int garr[4];
  modport mp(input clk, import t);
  task t(int s);
    @(posedge clk) s++;
    garr[s]++;
  endtask
endinterface
