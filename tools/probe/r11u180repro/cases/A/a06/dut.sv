// § classTpFormalMovesTs180
package pkg;
  class base_c; endclass
  class holder #(type CB=base_c);
    function void f(CB x);
    endfunction
  endclass
endpackage
module top();
pkg::holder c1;
endmodule
