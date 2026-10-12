// § badItemLocThroughInvalid288 — case inside with a range item
package cp;
  class tok;
    static function tok born(string s); born = new(); endfunction
  endclass
  class sh #(type SS = int);
    function void f(int k);
      case (k) inside
        [1:3]: begin
             SS v;
             v = SS::born("v");
           end
        5, 7: k = 0;
        default: begin
             SS u;
             u = SS::born("u");
           end
      endcase
    endfunction
  endclass
endpackage
module top; endmodule
