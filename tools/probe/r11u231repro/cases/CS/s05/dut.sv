// § tfArgClassSpecNameSpan231 — the formal written by a macro, and a `ref` / `const ref` formal
`define ACC(T) function void acc(proxy#(T) px); endfunction
package p;
  class proxy #(type S=int);
    S v;
  endclass
  class adapter;
    `ACC(int)
    function void r1(ref proxy#(int) rx, const ref proxy#(int) cx);
    endfunction
  endclass
endpackage
module top;
endmodule
