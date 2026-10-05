// § cloneTfFixedArrTsParented253 (two importer packages)
package p;
  function automatic int f(int k);
    int a[4];
    a[0] = k;
    return a[0];
  endfunction
endpackage
package q;
  import p::*;
endpackage
package r;
  import p::*;
endpackage
module top;
  import q::*;
  import r::*;
endmodule
