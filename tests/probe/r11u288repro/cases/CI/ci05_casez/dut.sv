// § badItemLocThroughInvalid288 — casez and casex items
package cp;
  class tok;
    static function tok born(string s); born = new(); endfunction
  endclass
  class sh #(type SS = int);
    function void f(logic [3:0] k);
      casez (k)
        4'b1???: begin
             SS v;
             v = SS::born("v");
           end
        default: k = 0;
      endcase
      casex (k)
        4'b01xx: begin
             SS u;
             u = SS::born("u");
           end
      endcase
    endfunction
  endclass
endpackage
module top; endmodule
