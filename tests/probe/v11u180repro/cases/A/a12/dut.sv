// § classTpDefaultTsAtUse180 (verifier: a class-typed parameter of a class inside a MODULE)
module top();
  class base_c; endclass
  class holder #(type CB=base_c);
    CB m;
    function void f(CB x); m = x; endfunction
  endclass
  holder h;
endmodule
