// § classTpDefaultTsAtUse180
class base_c; endclass
module top();
  class holder #(type CB=base_c);
    CB m;
    function void f();
      CB l;
      l = m;
    endfunction
  endclass
  holder c1;
endmodule
