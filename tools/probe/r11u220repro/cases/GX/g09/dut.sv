// § hpVarSelRangeIdxNamesByPath220
module top(input logic [39:0] din, input logic [3:0] en, output logic [3:0] o_pm, output logic o1, output logic o2);
  struct packed {
    logic [15:0]     vpn;
    logic [1:0][0:0] is_page;
    logic            valid;
    logic            pad;
  } [1:0] tq;
  assign tq = din;
  logic [1:0] ix;
  assign ix = din[1:0];
  assign o1 = tq[0].is_page[ix-1][0];
endmodule
