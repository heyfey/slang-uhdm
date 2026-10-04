// § tfArgTypeParamDefaultWriter231 — the default is a struct typedef
package p;
  typedef struct packed { logic [3:0] a; logic b; } s_t;
  class wrap #(type T=s_t);
    function void put(T v);
    endfunction
  endclass
endpackage
module top;
endmodule
