// § tfArgScalarTdWriter223
package p;
  typedef integer UVM_FILE;
  class c;
    function void f(
      /* lead */ UVM_FILE   /* mid */ x,
      input
        UVM_FILE
          y = 5
    );
    endfunction
  endclass
endpackage
module top;
  import p::*;
  UVM_FILE g;
endmodule
