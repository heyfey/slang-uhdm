// r10uvm85 arm a1 — THE HEAD'S FAMILY: STATEMENT-position
// `this.<member>.<builtin>(args)` over the built-in methods and arities the
// brief names (delete/push_back/pop_front/insert/sort, 0/1/2 args).
// Every cell is a Subroutine_call_statement whose child is an
// Implicit_class_handle, i.e. Surelog's paConstant_bit_select arm.
module g85a1;
  class c1;
    int      q[$];
    int      aa[string];
    int      n;
    string   s;
    function void f(int k);
      this.q.delete(0);          // L13 builtin 1 arg (THE HEAD's shape)
      this.q.delete();           // L14 builtin 0 args
      this.q.push_back(k);       // L15 builtin 1 arg, FORMAL actual
      this.q.push_front(this.n); // L16 builtin 1 arg, this-rooted actual
      this.q.insert(0, k);       // L17 builtin 2 args
      this.q.sort();             // L18 array-manipulation, 0 args
      this.q.reverse();          // L19
      this.q.shuffle();          // L20
      this.aa.delete("k");       // L21 assoc-array builtin, string actual
      this.aa.delete();          // L22
      this.q.delete(k + 1);      // L23 OPERATION actual
      this.q.delete(this.n);     // L24 this-rooted actual (deep-this ARG)
    endfunction
  endclass
endmodule
