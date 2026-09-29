// § incDecOperandKeepsLvalueForm215 — system call arguments
package p;
  class seq; int n; endclass
  class sqr;
    seq sp;
    function string show();
      $display("%0d", sp.n++);
      return $sformatf("%0d %0d", ++sp.n, sp.n--);
    endfunction
  endclass
endpackage
module m;
endmodule
