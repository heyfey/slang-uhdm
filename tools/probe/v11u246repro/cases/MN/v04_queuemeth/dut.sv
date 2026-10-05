// § macroParamMethNameEnd246
`define DO_Q(Q,METHOD) \
   begin \
     Q.METHOD; \
   end
module top;
  int q[$];
  class k;
    int qq[$];
    function void f();
      `DO_Q(qq, push_back(3))
      `DO_Q(qq, delete())
    endfunction
  endclass
  initial begin
    `DO_Q(q, push_back(1 + 2 + 3 + 4 + 5 + 6 + 7 + 8))
  end
endmodule
