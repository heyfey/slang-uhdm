// § sysCallTimeKwNameSpan270
package p;
  class c;
    function void f();
      time t = $time();
      $display("%0t %0t", $time(), $realtime());
    endfunction
  endclass
endpackage
module top;
  p::c o;
endmodule
