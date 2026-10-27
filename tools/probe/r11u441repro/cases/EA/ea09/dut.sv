// § sysCallEmptyArgEndPrevTok441
package p;
  function automatic void show(int a, int b);
    $display("x", a,
             , b);
  endfunction
endpackage
module top;
  initial p::show(1, 2);
endmodule
