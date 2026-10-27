// § uninstIfaceIncDecBinds441
interface ifc;
  int garr[4];
  task t(int s);
    begin
      int u;
      begin : nb
        u++;
      end
    end
  endtask
endinterface
