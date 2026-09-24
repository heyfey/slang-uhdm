package p;
  class fwd;
    function void caller(int a);
      later(a);
      voidlater();
    endfunction
    function void later(int a);
    endfunction
    function void voidlater();
    endfunction
    task tcaller(int a);
      tlater(a);
    endtask
    task tlater(int a);
    endtask
  endclass
endpackage

module top;
  import p::*;
  fwd f;
  initial f.caller(1);
endmodule
