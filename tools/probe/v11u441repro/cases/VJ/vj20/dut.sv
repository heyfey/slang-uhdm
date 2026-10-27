// § uninstIfaceIncDecBinds441
interface ifc;
  int garr[4];
  task t(int s);
    int a;
    begin : nb
      begin
        a++;
        s--;
      end
    end
  endtask
endinterface
