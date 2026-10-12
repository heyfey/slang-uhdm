// § badItemLocThroughInvalid288 — rejected blocks under a labelled block and in an out-of-body method
package cp;
  class tok;
    static function tok born(string s); born = new(); endfunction
  endclass
  class sh #(type SS = int);
    extern function void g(int k);
    function void f(int k);
      case (k)
        1: begin : lbl
             SS v;
             v = SS::born("v");
           end : lbl
      endcase
    endfunction
  endclass
  function void sh::g(int k);
    case (k)
      2: begin
           SS w;
           w = SS::born("w");
         end
      default: ;
    endcase
  endfunction
endpackage
module top; endmodule
