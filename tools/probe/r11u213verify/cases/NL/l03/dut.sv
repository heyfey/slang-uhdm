// § namedOrderLinkedDeclines207v § namedUnlinkedWrittenOrder207 (a parameterized class calling its own extern function prototype inside fork and a nested begin; an abstract class calling its pure virtual function skipping nothing)
package p;
  virtual class F #(int W = 2);
    extern function int mt(int a, int b = W, int c = 2);
    pure virtual function int pv(int a, int b, int c);
    task run(int x);
      int r;
      fork
        r = mt(.c(x), .b(1), .a(W));
      join
      begin : nb
        r = pv(.b(x), .c(W), .a(0));
      end
    endtask
  endclass
  function int F::mt(int a, int b = W, int c = 2); return a + b + c; endfunction
  class G extends F #(3);
    virtual function int pv(int a, int b, int c); return a; endfunction
  endclass
endpackage
module top; endmodule
