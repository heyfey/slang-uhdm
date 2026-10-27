// § unnamedLocalUnderNamedBinds441v
interface ifc;
  int garr[4];
  task t(int s);
    begin : outer
      begin
        begin : inner
          begin
            int z;
            z++;
          end
        end
      end
    end
  endtask
endinterface
