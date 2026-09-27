// § invalidStmtAnchorSyntax181 (v11u181 break: the unbound second item in a class-in-module method, with an automatic local first, and a bound third item)
module top;
  class tk; static function tk mk(); mk = new(); endfunction endclass
  class G #(type T = int);
    int n;
    function void f1(); int loc = 1; T::mk(); n = loc; endfunction
    function void f2(); n = 2; T::mk(); n = 3; endfunction
  endclass
endmodule
