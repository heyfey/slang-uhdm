// § clsTdMemberContainerPath279
module top;
  class outer_c;
    class inner_c;
      typedef union packed { logic [3:0] a; logic [3:0] b; } iu_t;
    endclass
    function void f(); inner_c::iu_t v; v.a = 1; endfunction
  endclass
  outer_c oc;
  initial oc = new();
endmodule
