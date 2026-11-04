// § badItemLocThroughInvalid288 — a rejected body in a case inside and a case nested inside another case item
package cp;
  class tok; static function tok born(string s); born = new(); endfunction endclass
  class sh #(type SS = int);
    function void f(int k);
      case (k) inside
        [0:3]: begin SS v; v = SS::born("a"); end
        default: case (k)
          9: begin SS w; w = SS::born("b"); end
          default: k = 1;
        endcase
      endcase
    endfunction
  endclass
endpackage
module top; endmodule
