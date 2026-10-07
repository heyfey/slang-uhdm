// § clsTdMemberContainerPath279
package px;
  typedef struct packed { logic [1:0] q; } ps_t;
  class outer_c;
    class inner_c;
      typedef struct { ps_t a; int b; } irec_t;
    endclass
    function void f(); inner_c::irec_t v; v.b = 1; endfunction
  endclass
endpackage
module top;
  px::outer_c oc;
  initial oc = new();
endmodule
