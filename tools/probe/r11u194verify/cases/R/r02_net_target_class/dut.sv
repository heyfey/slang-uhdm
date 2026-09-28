// § rootLvalueSpanAtRoot184: a $root net as a continuous-assignment target, a $root member target, and a $root target inside a module class's method called from an initial block
module top;
  wire [3:0] w;
  logic [3:0] q;
  typedef struct packed { logic [1:0] a; logic [1:0] b; } s_t;
  s_t st;
  class c;
    function void poke();
      $root.top.q = 4'h9;
    endfunction
  endclass
  assign $root.top.w = q;
  initial begin
    c h;
    h = new;
    h.poke();
    $root.top.st.a = 2'd1;
  end
endmodule
