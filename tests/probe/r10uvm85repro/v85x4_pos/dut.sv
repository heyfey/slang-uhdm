// v85x4 — POSITIONS the a7 arm does not reach: foreach, repeat, forever,
// do-while, nested fork flavours, labelled/nested blocks, a delayed statement,
// a statement inside a `randcase`, and a deep-`this` call inside another call's
// argument list (which is NOT statement position and must keep uvm84's shape).
module v85x4;
  class in4v;
    int arr[$];
    int fld;
  endclass
  class c4v;
    in4v     h;
    int      q[$];
    int      n;
    function void g(int a); endfunction
    task tk(int k);
      foreach (this.q[j])
        this.q.delete(j);              // L17 FOREACH body, iterator actual
      repeat (2)
        this.q.delete(k);              // L19 REPEAT body
      do
        this.q.delete(0);              // L21 DO body
      while (this.n > 0);
      fork
        this.q.delete(1);              // L24 fork/join arm 1
        this.q.push_back(k);           // L25 fork/join arm 2
      join
      fork
        begin
          this.q.delete(2);            // L29 fork/join_any nested begin
        end
      join_any
      begin : outer4
        begin : inner4
          this.q.delete(3);            // L34 doubly-nested named block
        end
      end
      #1 this.q.delete(4);             // L37 DELAYED statement
      if (k > 0) begin
        case (k)
          1, 2: this.q.delete(5);      // L40 multi-label case item
          default: ;
        endcase
      end
      this.g(this.h.fld);              // L44 rvalue deep-this as an ARGUMENT
      this.q.push_back(this.h.fld);    // L45 rvalue deep-this as builtin ARG
      forever begin
        this.q.delete(6);              // L47 FOREVER body
        break;
      end
    endtask
  endclass
endmodule
