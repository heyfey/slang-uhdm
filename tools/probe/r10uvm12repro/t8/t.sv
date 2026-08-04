package p;
  class c;
    int prop;
    task early(int a);
    endtask
    function void efun(int a);
    endfunction
    task caller(int a);
      early(a);
      efun(a);
      lateT(a);
      lateF(prop);
    endtask
    task lateT(int a);
    endtask
    function void lateF(int a);
    endfunction
  endclass
endpackage

module top;
  import p::*;
  c h;
  initial h.caller(1);
endmodule
