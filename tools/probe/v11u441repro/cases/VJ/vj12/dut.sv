// § uninstIfaceIncDecBinds441
interface ifc;
  int garr[4];
  task automatic t(ref int s, inout int o, output int w);
    s++;
    o--;
    w++;
  endtask
  final begin
    int z;
    z++;
  end
endinterface
