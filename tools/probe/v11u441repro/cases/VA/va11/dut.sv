// § sysCallEmptyArgEndPrevTok441
package p;
  function automatic void f(int a, int b);
    $display("x", a,
             , b);
  endfunction
endpackage
module top;
  initial p::f(1, 2);
endmodule
