// § progLocalDeclNets444
program automatic prg;
int x;
task t();
  int loc;
  loc = x;
endtask
function int f();
  int y;
  y = 2;
  return y;
endfunction
initial begin t(); x = f(); end
endprogram
