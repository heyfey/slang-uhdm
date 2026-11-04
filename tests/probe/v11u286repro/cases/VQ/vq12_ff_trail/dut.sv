// § genLvTrailSelCallWhole286v
module top (input clk);
  typedef struct packed { logic [1:0] b; } e_t;
  typedef struct packed { e_t [3:0] arr; } s_t;
  s_t [1:0] ts;
  e_t [3:0] m;
  function automatic int fn(int a); return a; endfunction
  if (1) begin : gi
    always_ff @(posedge clk) m[2].b[fn(1)] <= 1'b0;
  end
endmodule
