// § hpTrailIpsNamesByPath218 — a path's trailing indexed part select whose base is a reference and whose width is a parameter, in a function body and a continuous assignment
module top #(parameter int W = 4)(input logic [31:0] d, input logic [2:0] k, output logic [3:0] o1, output logic [3:0] o2);
  typedef struct packed { logic [31:0] f; } s_t;
  s_t s;
  assign s.f = d;
  function automatic logic [3:0] pick(input s_t v, input logic [2:0] j);
    return v.f[j*4 +: W];
  endfunction
  assign o1 = pick(s, k);
  assign o2 = s.f[k*4 -: W];
endmodule
