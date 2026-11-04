// § invalidStmtAnchorSyntax181 — break hunt: the unbound statement first, alone, last of three, in a task, and a bound control
package p;
  class tk; static function tk mk(); mk = new(); endfunction endclass
  class G #(type T = int);
    int n;
    function void f1(); T::mk(); n = 1; endfunction
    function void f2(); n = 2; T::mk(); endfunction
    function void f3(); T::mk(); endfunction
    function void f4(); n = 3; n = 4; T::mk(); endfunction
    task t1(); n = 5; T::mk(); endtask
    function void f5(); n = 6; tk::mk(); endfunction
  endclass
endpackage
module top; endmodule
