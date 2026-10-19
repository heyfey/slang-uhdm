// § typedCtorNotProgram411v
program top;
  class B; int s = 2; endclass
  class C extends B; function new(); s = 3; endfunction endclass
  B o;
  initial begin
    o = C::new;
    $display(o.s);
  end
endprogram
