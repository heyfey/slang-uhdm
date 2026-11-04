// § genProcLvIdxCallSpan286 — member path lvalue with a call index; read path index control
module dut ();
  typedef struct packed { logic [3:0] v; } s_t;
  s_t m [4];
  s_t n [4];
  logic [3:0] o;
  function automatic int fn(input int x); return x; endfunction
  for (genvar f = 0; f < 1; f++) begin : gf
    always_comb begin
      m[fn(1)].v = 4'h3;
      o = n[fn(2)].v;
    end
  end
endmodule
