// § classTpFormalMovesTs180
package pkg;
  class base_c; endclass
  class holder #(type CB=base_c);
    CB m;
    function void f(CB x);
      m = x;
    endfunction
    function void g(int k, CB y);
      m = y;
    endfunction
  endclass
endpackage
module top();
pkg::holder c1;
endmodule
