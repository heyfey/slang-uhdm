// § badItemLocThroughInvalid288 — a task, a nested case inside a good item, a unique case
package cp;
  class tok;
    static function tok born(string s); born = new(); endfunction
  endclass
  class sh #(type SS = int);
    task t(int k, int j);
      unique case (k)
        0: case (j)
             1: begin
                  SS v;
                  v = SS::born("v");
                end
           endcase
        1: begin
             SS u;
             u = SS::born("u");
           end
      endcase
    endtask
  endclass
endpackage
module top; endmodule
