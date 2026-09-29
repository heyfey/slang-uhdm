// § hpVarSelRangeIdxNamesByPath220
module top(input logic [41:0] din, input logic [1:0] ix, output logic [1:0] o);
  typedef struct packed { logic [15:0] vpn; logic [1:0][3:0] pg; logic v; } s_t;
  s_t [1:0] tq;
  assign tq = din;
  function automatic logic [1:0] f(input logic [1:0] k);
    return tq[0].pg[k-1][1:0];
  endfunction
  assign o = f(ix);
endmodule
