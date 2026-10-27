// § uninstIfaceIncDecBinds441
interface ifc;
  int garr[4];
  task t(int s);
    begin : nb
      int loc;
      begin
        loc++;
      end
    end
  endtask
endinterface
