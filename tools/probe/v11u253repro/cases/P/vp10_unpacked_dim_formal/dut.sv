// § cloneFormalTsParented253 (unpacked and dynamic array formals)
package p;
  parameter W = 8;
  function automatic int f(input logic [W:0] s [2], input int d[], input string q[$]);
    return s[0] + d.size() + q.size();
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import q::*;
endmodule
