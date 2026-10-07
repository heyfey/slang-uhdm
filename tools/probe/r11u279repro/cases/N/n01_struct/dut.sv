// § clsTdMemberContainerPath279
package px;
  class outer_c;
    class inner_c;
      typedef struct { int a; logic [3:0] b; } irec_t;
    endclass
    function void f();
      inner_c::irec_t v;
      v.a = 1;
    endfunction
  endclass
endpackage
module top;
  px::outer_c oc;
  initial oc = new();
endmodule
