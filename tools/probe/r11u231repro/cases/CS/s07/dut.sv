// § tfArgClassSpecNameSpan231 — control: a package-qualified specialization and an unparameterized class
package q;
  class proxy #(type S=int);
    S v;
  endclass
  class plain;
    int x;
  endclass
endpackage
package p;
  class adapter;
    function void f(q::proxy#(int) px, q::plain pl);
    endfunction
  endclass
endpackage
module top;
endmodule
