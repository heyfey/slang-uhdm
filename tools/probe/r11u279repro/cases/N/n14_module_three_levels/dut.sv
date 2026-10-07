// § clsTdMemberContainerPath279
module top;
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
  outer_c oc;
  initial oc = new();
endmodule
