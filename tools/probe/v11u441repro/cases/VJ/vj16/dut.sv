// § unnamedLocalUnderNamedBinds441v
interface ifc;
  int garr[4];
  initial begin : nb
    begin
      int inner;
      inner++;
    end
  end
endinterface
