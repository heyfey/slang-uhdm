// § hpPartSelBoundNamesBySelect154
module top(input logic [7:0] i, output logic [3:0] o);
  localparam int GW = 4;
  typedef struct packed { logic [7:0] wdt; } s_t;
  function automatic logic [3:0] f(s_t s);
    return s.wdt[GW-1:0];
  endfunction
  s_t v;
  assign v = i;
  assign o = f(v);
endmodule
