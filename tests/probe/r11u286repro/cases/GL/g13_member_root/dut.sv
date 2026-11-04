// § genProcLvIdxCallSpan286 — member-path lvalues in a generate process: plain root spans the call, a selected root (and a later element of it) abstains
module dut ();
  typedef struct packed { logic [3:0] v; } s_t;
  typedef struct packed { s_t [3:0] arr; logic [3:0] w; } t_t;
  s_t m [4];
  t_t s;
  t_t ts [4];
  function automatic int fn(input int x); return x; endfunction
  for (genvar f = 0; f < 1; f++) begin : gf
    always_comb begin
      s.arr[fn(1)] = 4'h3;
    end
    always_comb begin
      m[fn(1)].v = 4'h3;
    end
    always_comb begin
      ts[fn(0)].w = 4'h2;
      ts[1].arr[fn(3)].v = 4'h1;
    end
  end
endmodule
