// § badItemLocThroughInvalid288 — default written FIRST and rejected; a param-valued item
package cp;
  class tok;
    static function tok born(string s); born = new(); endfunction
  endclass
  class sh #(type SS = int, int P = 2);
    function void f(int k);
      case (k)
        default: begin
             SS v;
             v = SS::born("v");
           end
        P: begin
             SS u;
             u = SS::born("u");
           end
        P + 1: k = 0;
      endcase
    endfunction
  endclass
endpackage
module top; endmodule
