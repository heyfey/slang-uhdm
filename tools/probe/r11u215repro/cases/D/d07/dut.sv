// § incDecOperandKeepsLvalueForm215 — a task call and a module's call of a class method
package p;
  class seq;
    int n;
    function void put(int i); endfunction
  endclass
endpackage
module m;
  import p::*;
  seq q;
  task automatic t(int i); endtask
  initial begin
    q = new;
    t(q.n++);
    q.put(++q.n);
  end
endmodule
