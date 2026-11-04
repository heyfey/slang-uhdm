// § progLocalDeclNets444
program prg;
int x;
task automatic t();
  begin : nb
    int inner;
    inner = x;
  end
  begin
    int un;
    un = x;
  end
endtask
initial t();
endprogram
