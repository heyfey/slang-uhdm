// § badItemLocThroughInvalid288 — an item listing two expressions
package cp;
  class tok;
    static function tok born(string s); born = new(); endfunction
  endclass
  class sh #(type SS = int);
    function void f(int k);
      case (k)
        1, 2: begin
             SS v;
             v = SS::born("v");
           end
        3: k = 4;
      endcase
    endfunction
  endclass
endpackage
module top; endmodule
