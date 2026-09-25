// § hpSelRoute157
typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
interface ifc (input logic clk);
  s_t st; logic [7:0] v; logic [3:0] q, r;
  always_comb begin
    q = v[st.a +: 2];
    r = v[st.b[2:0]];
  end
  function automatic logic [1:0] pick(input s_t x); return v[x.a[1:0] +: 2]; endfunction
endinterface
module top (input logic clk); ifc u(.clk(clk)); endmodule
