// § cloneTfItemLocalOwnVar253 (two importer packages)
package p;
  function automatic int f;
    int x;
    x = 2;
    return x;
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
