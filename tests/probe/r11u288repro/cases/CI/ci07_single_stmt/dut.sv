// § badItemLocThroughInvalid288 — a rejected SINGLE statement as the item body (no block)
package cp;
  class tok;
    static function tok born(string s); born = new(); endfunction
  endclass
  class sh #(type SS = int);
    SS m;
    function void f(int k);
      case (k)
        1: m = SS::born("m");
        2: k = 1;
        default: m = SS::born("d");
      endcase
    endfunction
  endclass
endpackage
module top; endmodule
