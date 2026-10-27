// § uninstIfaceIncDecBinds441
interface ifc;
  int garr[4];
  task t(int s);
    int loc;
    garr[s]++;
    loc++;
  endtask
endinterface
module top;
endmodule
