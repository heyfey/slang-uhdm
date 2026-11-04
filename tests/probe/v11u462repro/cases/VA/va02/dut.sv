// § clsMethodOwnAutomatic462
package p;
  class C;
    task automatic t(); endtask
    function automatic int f(); return 1; endfunction
  endclass
endpackage
module top;
  import p::*;
  C c;
endmodule
