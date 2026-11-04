// § cloneAggLocalOwnCopy241
package p;
  typedef struct packed {
    logic [3:0] a;
    logic [3:0] b;
  } pk_t;
  function automatic int f1(pk_t x);
    pk_t loc;
    loc = x;
    begin
      pk_t inner;
      inner = loc;
      return int'(inner.a);
    end
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import p::*;
  int y;
  initial y = f1(8'h12);
endmodule
