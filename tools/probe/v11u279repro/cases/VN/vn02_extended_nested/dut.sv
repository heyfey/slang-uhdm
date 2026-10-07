// § clsTdMemberContainerPath279
package px;
  class outer_c;
    class inner_c;
      typedef struct packed { logic [3:0] a; logic b; } irec_t;
    endclass
  endclass
  class der_c extends outer_c;
    function void f(); inner_c::irec_t v; v.a = 1; endfunction
  endclass
endpackage
module top;
  px::der_c d;
  initial d = new();
endmodule
