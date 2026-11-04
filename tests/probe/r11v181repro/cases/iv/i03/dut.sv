// § invalidStmtAnchorSyntax181 (v11u181 break: an unbound method call on a type-parameter handle as the second item, and a bound control in a specialised class)
package p;
  class tk; function void go(int a); endfunction static function tk mk(); mk = new(); endfunction endclass
  class G #(type T = int);
    T h;
    int n;
    function void f1(); n = 1; h.go(n); endfunction
    function void f2(); n = 2; h = T::mk(); endfunction
  endclass
  class S;
    G #(tk) g;
  endclass
endpackage
module top; endmodule
