// § hpBaseSelOpIdxNamesByPath145
typedef struct packed { logic v; logic [3:0] r; } s_t;
module dut(input s_t [3:0] sd, input logic [1:0] k, output logic o);
  function automatic logic [1:0] f(logic [1:0] x); return x; endfunction
  assign o = sd[f(k) + 1].v;
endmodule
