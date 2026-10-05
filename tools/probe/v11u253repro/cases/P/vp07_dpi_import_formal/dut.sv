// § cloneFormalTsParented253 (a DPI import beside a subroutine)
package p;
  parameter W = 8;
  import "DPI-C" function int d(input bit [W:0] x);
  function automatic int f(bit [W:0] s); return d(s); endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import q::*;
endmodule
