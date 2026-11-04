// § cloneAggTsAtHomeListing241
package r;
  typedef enum logic [1:0] { R_A, R_B } e_t;
  function automatic int rf(e_t w);
    return int'(w);
  endfunction
endpackage
package p;
  import r::*;
  function automatic int f1(e_t y);
    e_t le;
    le = y;
    return int'(le);
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import p::*;
  int z;
  initial z = f1(r::R_B);
endmodule
