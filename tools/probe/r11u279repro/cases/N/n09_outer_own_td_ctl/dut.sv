// § clsTdMemberContainerPath279
package px;
  class outer_c;
    typedef struct { int a; } orec_t;
    function void f();
      orec_t v;
      v.a = 1;
    endfunction
  endclass
endpackage
module top;
  px::outer_c oc;
  initial oc = new();
endmodule
