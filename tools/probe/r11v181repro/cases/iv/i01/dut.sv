// § invalidStmtAnchorSyntax181 (v11u181 break: the unbound second item labelled, spread over two lines, with a trailing comment, macro-born, and an unbound assignment)
`define CALLMK T::mk();
package p;
  class tk; static function tk mk(); mk = new(); endfunction static int v; endclass
  class G #(type T = int);
    int n;
    function void f1(); n = 1; lbl: T::mk(); endfunction
    function void f2();
      n = 2;
      T::mk(
      );  // trailing
    endfunction
    function void f3(); n = 3; `CALLMK endfunction
    function void f4(); n = 4; n = T::v; endfunction
    task t1(); n = 5; void'(T::mk()); endtask
  endclass
endpackage
module top; endmodule
