// § pkgLeafPatLocByWriting152
package pk;
  typedef struct packed { logic a; logic b; } s_t;
endpackage
module top import pk::*; (input logic [5:0] i, output int x);
  function automatic s_t [2:0] f(logic [5:0] v);
    return v;
  endfunction
  assign x = int'(f(i));
endmodule
