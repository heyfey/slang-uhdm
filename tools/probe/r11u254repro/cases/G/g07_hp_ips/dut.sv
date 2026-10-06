// § genCaPsBoundOpChain254 (an indexed part-select of a member path inside a for-generate continuous assignment: operation width and base, the Earlgrey xbar fifo shape)
typedef struct packed { logic [7:0] a_source; logic v; } tl_t;
module top #(parameter int W = 8) (input tl_t tl_h_i [3], output logic [5:0] o [3], output logic [1:0] p [3]);
  for (genvar i = 0; i < 3; i++) begin : gen_host_fifo
    assign o[i] = {tl_h_i[i].a_source[0 +: W-2]};
    assign p[i] = tl_h_i[i].a_source[W-1 -: 2];
  end
endmodule
