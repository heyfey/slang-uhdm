// § uninstIfaceIncDecBinds441
interface ifc;
  int garr[4];
  task t(int s);
    fork
      begin
        int q;
        q++;
        garr[s]++;
      end
    join_none
    #1 s++;
  endtask
endinterface
