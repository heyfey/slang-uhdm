// § badItemLocThroughInvalid288 — a case item whose body block slang rejects
package cp;
  class tok;
    static function tok born(string s); born = new(); endfunction
  endclass
  class sh #(type SS = int);
    function void f(int k);
      case (k)
        1: begin
             SS v;
             v = SS::born("v");
           end
        default: begin
             int w;
             w = 3;
           end
      endcase
    endfunction
  endclass
endpackage
module top; endmodule
