// § incDecOperandKeepsLvalueForm215 — controls: a this. path and a plain variable as the operand (the law does not apply)
package p;
  function automatic void take(int i); endfunction
  class sqr;
    int n;
    function void send();
      int k;
      take(this.n++);
      take(++this.n);
      take(k++);
      take(++k);
    endfunction
  endclass
endpackage
module m;
endmodule
