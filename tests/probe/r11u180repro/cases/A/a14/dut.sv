// § classTpFormalMovesTs180
package pkg;
  class base_c; endclass
  class holder #(type CB=base_c);
    CB m;
    function void f(CB x);
      CB l;
      l = x;
    endfunction
  endclass
endpackage
module top();
pkg::holder c1;
endmodule
