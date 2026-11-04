// § clsTdMemberContainerPath279
module sub;
  class outer_c;
    class inner_c;
      typedef struct { int a; } irec_t;
    endclass
    function void f(); inner_c::irec_t v; v.a = 1; endfunction
  endclass
  outer_c oc;
  initial oc = new();
endmodule
module top;
  sub s1();
  sub s2();
endmodule
