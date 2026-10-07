// § clsTdMemberContainerPath279
module top;
  class outer_c #(int W = 2);
    typedef struct { logic [W-1:0] a; } orec_t;
    function void f(); orec_t v; v.a = 1; endfunction
  endclass
  outer_c #(3) oc;
  initial oc = new();
endmodule
