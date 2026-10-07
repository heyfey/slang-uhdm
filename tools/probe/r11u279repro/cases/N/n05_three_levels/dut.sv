// § clsTdMemberContainerPath279
package px;
  class outer_c;
    class mid_c;
      class inner_c;
        typedef struct { int a; } irec_t;
      endclass
    endclass
    function void f();
      mid_c::inner_c::irec_t v;
      v.a = 1;
    endfunction
  endclass
endpackage
module top;
  px::outer_c oc;
  initial oc = new();
endmodule
