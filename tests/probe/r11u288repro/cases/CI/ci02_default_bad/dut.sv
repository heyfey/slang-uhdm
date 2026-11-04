// § badItemLocThroughInvalid288 — the DEFAULT arm's block is the rejected one
package cp;
  class tok;
    static function tok born(string s); born = new(); endfunction
  endclass
  class sh #(type SS = int);
    function void f(int k);
      case (k)
        1: begin
             int w;
             w = 3;
           end
        default: begin
             SS v;
             v = SS::born("v");
           end
      endcase
    endfunction
  endclass
endpackage
module top; endmodule
