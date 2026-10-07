// § clsTdMemberContainerPath279
package px;
  class outer_c;
    typedef logic [3:0] nib_t;
    class inner_c;
      typedef struct { nib_t a; int b; } irec_t;
    endclass
    function void f(); inner_c::irec_t v; v.b = 1; endfunction
  endclass
endpackage
module top;
  px::outer_c oc;
  initial oc = new();
endmodule
