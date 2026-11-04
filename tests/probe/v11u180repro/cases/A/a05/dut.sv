// § classTpFormalMovesTs180 (verifier: a task ref formal, then the constructor formal is the last writer)
package pkg;
  class base_c; endclass
  class holder #(type CB=base_c);
    CB m;
    task put(ref CB x);
      m = x;
    endtask
    function new(CB c = null);
      m = c;
    endfunction
  endclass
endpackage
module top();
pkg::holder c1;
endmodule
