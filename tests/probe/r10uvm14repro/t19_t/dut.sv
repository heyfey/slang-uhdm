// uvm_pair shapes: dotted calls on type-parameter-typed PROPERTIES, in a
// system-call argument, in an operation, with a dotted ACTUAL, and the
// `prop = new;` constructor form.
package p3;
  class pr #(type T1 = int, type T2 = T1);
    T1 first;
    T2 second;
    function new(string name = "", T1 f = null, T2 s = null);
      if (f == null)
        first = new;                                   // A: `= new` on a T
      else
        first = f;
    endfunction
    virtual function string convert2string;
      string q;
      $sformat(q, "pair : %s, %s",
               first.convert2string(), second.convert2string()); // B: sys arg
      return q;
    endfunction
    virtual function bit do_compare(pr rhs_);
      return first.compare(rhs_.first) && second.compare(rhs_.second); // C
    endfunction
    virtual function void do_copy(pr rhs_);
      first.copy(rhs_.first);                          // D: dotted ACTUAL
      second.copy(rhs_.second);
    endfunction
  endclass
endpackage

module top;
  import p3::*;
  initial;
endmodule
