class B extends A;
  extern function new();
endclass
function B::new();
  int rb;
  super.new();
  rb = 1;
endfunction
