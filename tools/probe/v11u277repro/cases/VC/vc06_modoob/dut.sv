// § ctorRetVarSiblingSpan277
module top;
  class mo #(int W = 2);
    logic [W-1:0] q;
    extern function new(input logic [W-1:0] v);
  endclass
  function mo::new(input logic [W-1:0] v);
    q = v;
  endfunction
  mo #(4) h;
  mo #(8) h2;
endmodule
