// § cloneTfFixedArrTsParented253 (a paren-less function's fixed local)
package p;
  function automatic int f;
    int a[4];
    a[0] = 1;
    return a[0];
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import q::*;
endmodule
