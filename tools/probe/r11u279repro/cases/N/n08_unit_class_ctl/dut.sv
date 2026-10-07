// § clsTdMemberContainerPath279
class outer_c;
  class inner_c;
    typedef struct { int a; } irec_t;
  endclass
  function void f();
    inner_c::irec_t v;
    v.a = 1;
  endfunction
endclass
module top;
  outer_c oc;
  initial oc = new();
endmodule
