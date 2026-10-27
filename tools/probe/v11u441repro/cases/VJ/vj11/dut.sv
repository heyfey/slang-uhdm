// § unnamedLocalUnderNamedBinds441v
interface ifc;
  int garr[4];
  task t(int s);
    begin : nb
      int loc;
      begin
        int inner;
        inner++;
        garr[s]++;
      end
    end
  endtask
endinterface
