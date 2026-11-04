// § clsTdMemberContainerPath279
package px;
`define TD typedef struct { int a; } irec_t;
  class outer_c;
    class inner_c;
      `TD
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
