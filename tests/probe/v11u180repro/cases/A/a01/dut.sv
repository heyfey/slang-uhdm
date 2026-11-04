// § classTpFormalMovesTs180 (verifier: a queue formal written as the type parameter, then a property use)
package pkg;
  class base_c; endclass
  class holder #(type CB=base_c);
    CB m;
    function void f(CB x[$]);
    endfunction
  endclass
endpackage
module top();
pkg::holder c1;
endmodule
