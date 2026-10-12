// § badItemLocThroughInvalid288 — a string item (implicit conversion around the item expression)
package cp;
  class tok;
    static function tok born(string s); born = new(); endfunction
  endclass
  class sh #(type SS = int);
    string sk;
    function void f();
      case (sk)
        "a": begin
               SS v;
               v = SS::born("v");
             end
        "b", "c": sk = "d";
        default: sk = "e";
      endcase
    endfunction
  endclass
endpackage
module top; endmodule
