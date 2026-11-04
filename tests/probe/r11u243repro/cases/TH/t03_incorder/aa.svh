class ac;
  extern function void f();
endclass
function void ac::f();
  $display("%p", this);
endfunction
