// § hpBaseSelOpIdxNamesByPath145
typedef struct packed { logic v; logic [3:0] r; } s_t;
module dut(input s_t [3:0] sd, input logic [1:0] i, output logic o);
  function automatic logic f(input s_t [3:0] x, input logic [1:0] k);
    return x[k+1].v;
  endfunction
  assign o = f(sd, i);
endmodule
