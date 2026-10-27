// § progLocalDeclNets444
program prg;
class C;
  extern task t();
endclass
task C::t();
  int z;
  z = 1;
endtask
int y;
initial begin C c; c = new; c.t(); end
endprogram
