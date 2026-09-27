// § classTpDefaultTsAtUse180
class base_c; endclass
class holder #(type CB=base_c);
  function void f();
    CB cb;
    cb = null;
  endfunction
endclass
module top();
holder c1;
endmodule
