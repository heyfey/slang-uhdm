// § clsTdMemberContainerPath279
module top;
  class outer_c;
    typedef struct { int a; } orec_t;
    function void f();
      orec_t v;
      v.a = 1;
    endfunction
  endclass
  outer_c oc;
  initial oc = new();
endmodule
