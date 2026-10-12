// § badItemLocThroughInvalid288 — a rejected single-statement body on a multi-expression item, and an expression-statement body
package cp;
  class tok; static function tok born(string s); born = new(); endfunction endclass
  class sh #(type SS = int);
    SS keep;
    function void f(int k);
      case (k)
        1, 2, 3: keep = SS::born("a");
        4: void'(SS::born("b"));
        default: keep = SS::born("c");
      endcase
    endfunction
  endclass
endpackage
module top; endmodule
