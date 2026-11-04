// § badItemLocThroughInvalid288 — a rejected case item body in a unique case inside a class task and a priority casez
package cp;
  class tok; static function tok born(string s); born = new(); endfunction endclass
  class sh #(type SS = int);
    task t(int k);
      unique case (k)
        1: begin SS v; v = SS::born("a"); end
        2: k = 3;
      endcase
      priority casez (k)
        4'b1???: begin SS w; w = SS::born("b"); end
        default: k = 0;
      endcase
    endtask
  endclass
endpackage
module top; endmodule
