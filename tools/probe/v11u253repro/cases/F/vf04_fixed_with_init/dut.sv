// § cloneTfFixedArrTsParented253 (a fixed local with an assignment pattern initializer)
package p;
  function automatic int f(int k);
    int a[3] = '{1, 2, 3};
    byte b[0:1] = '{default: 0};
    return a[k] + b[0];
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import q::*;
endmodule
