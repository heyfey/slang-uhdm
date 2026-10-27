// § progLocalDeclNets444
interface ifc; logic v; endinterface
program prg;
int x;
task automatic t(virtual ifc vi);
  virtual ifc lv;
  lv = vi;
  x = lv.v;
endtask
endprogram
