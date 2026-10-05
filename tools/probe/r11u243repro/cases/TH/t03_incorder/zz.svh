class zc;
  extern function void f();
endclass

function void zc::f();
  $display("%p", this);
endfunction
