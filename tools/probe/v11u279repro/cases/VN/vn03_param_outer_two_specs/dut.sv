// § clsTdMemberContainerPath279
package px;
  class outer_c #(int W = 4);
    class inner_c;
      typedef struct { logic [3:0] a; int b; } irec_t;
    endclass
    function void f(); inner_c::irec_t v; v.b = W; endfunction
  endclass
endpackage
module top;
  px::outer_c #(8) o8;
  px::outer_c #(16) o16;
  initial begin o8 = new(); o16 = new(); end
endmodule
