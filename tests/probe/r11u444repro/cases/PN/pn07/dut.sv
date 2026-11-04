// § progLocalDeclNets444
program prg;
int x;
class C;
  function int f();
    int cl;
    cl = 1;
    return cl;
  endfunction
endclass
task automatic t();
  int loc;
  loc = x;
endtask
initial t();
endprogram
