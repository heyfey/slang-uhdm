package pk; parameter int unsigned IC_LINE_BEATS = 4; parameter int unsigned IC_LINE_BEATS_W = $clog2(IC_LINE_BEATS); endpackage
module top import pk::*; #(parameter int unsigned NUM_FB = 4) (input logic [NUM_FB-1:0] fill_alloc, input logic fill_spec_done, input logic [NUM_FB-1:0] fill_ext_arb, input logic instr_gnt_i, output logic [NUM_FB-1:0][IC_LINE_BEATS_W:0] fill_ext_cnt_d);
  logic [NUM_FB-1:0][IC_LINE_BEATS_W:0] fill_ext_cnt_q;
  assign fill_ext_cnt_q = fill_ext_cnt_d;
  for (genvar fb = 0; fb < NUM_FB; fb++) begin : gen_fbs
    assign fill_ext_cnt_d[fb]  = fill_alloc[fb] ?
                                   {{IC_LINE_BEATS_W{1'b0}},fill_spec_done} :
                                   (fill_ext_cnt_q[fb] + {{IC_LINE_BEATS_W{1'b0}},
                                                          fill_ext_arb[fb] & instr_gnt_i});
  end
endmodule
