// § clsTdMemberContainerPath279
package px;
  class outer_c #(int N = 2);
    class inner_c;
      typedef struct { int a; } irec_t;
    endclass
    function void f();
      inner_c::irec_t v;
      v.a = N;
    endfunction
  endclass
endpackage
module top;
  px::outer_c #(3) oc;
  initial oc = new();
endmodule
