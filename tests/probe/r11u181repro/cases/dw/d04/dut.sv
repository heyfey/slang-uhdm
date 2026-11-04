// § doWhileSyntaxFromCond181 — a do-while whose body declares a local in a parameterized class method (r10v158 v158_d's shape)
package p;
  class tok; static function tok mk(); mk = new(); endfunction endclass
  class C #(type T = int);
    int n;
    task t();
      do begin
        T x;
        x = T::mk();
        n = n - 1;
      end while (n > 0);
    endtask
  endclass
endpackage
module top; endmodule
