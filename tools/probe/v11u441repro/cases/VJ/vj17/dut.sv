// § unnamedLocalUnderNamedBinds441v
program prg;
  int garr[4];
  task t(int s);
    begin : nb
      begin
        int inner;
        inner++;
        garr[s]++;
      end
    end
  endtask
endprogram
