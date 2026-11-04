// § progLocalDeclNets444
program prg;
class C;
  int v;
  function int get(); int tmp; tmp = v; return tmp; endfunction
endclass
task automatic t();
  C h;
  h = new;
  h.v = 3;
endtask
initial t();
endprogram
