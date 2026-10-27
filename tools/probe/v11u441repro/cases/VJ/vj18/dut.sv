// § uninstIfaceIncDecBinds441
interface ifc;
  int garr[4];
  task t(int s);
    int loc;
    garr[loc]++;
    begin
      begin
        int deep;
        deep++;
        garr[deep]--;
      end
    end
  endtask
endinterface
