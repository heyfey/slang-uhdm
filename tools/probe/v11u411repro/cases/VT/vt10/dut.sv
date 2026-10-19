// § typedCtorNotProgram411v
class B; int s = 2; endclass
class C extends B; function new(int v); s = v; endfunction endclass
program top;
  B o;
  task automatic t(); o = C::new(4); endtask
  initial begin
    t();
    o = C::new(5);
  end
endprogram
