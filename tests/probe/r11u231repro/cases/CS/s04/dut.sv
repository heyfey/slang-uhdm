// § tfArgClassSpecNameSpan231 — a value-parameterized class and a named argument
package p;
  class box #(int W=8, type T=int);
    T d;
  endclass
  class user;
    function void f(box#(16) b1, box#(.W(4), .T(byte)) b2);
    endfunction
  endclass
endpackage
module top;
endmodule
