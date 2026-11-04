// § incDecOperandKeepsLvalueForm215 — a select index and a ternary arm hold the operator
package p;
  class seq; int n; endclass
  class sqr;
    seq sp;
    int arr[8];
    function int f(bit c);
      arr[sp.n++] = 1;
      f = arr[++sp.n];
      f = c ? sp.n++ : 0;
    endfunction
  endclass
endpackage
module m;
endmodule
