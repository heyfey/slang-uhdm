// § hpVarSelRangeIdxNamesByPath220
module top(input logic [39:0] din, input logic [3:0] en, output logic [3:0] o_pm, output logic o1, output logic o2);
  struct packed {
    logic [15:0]     vpn;
    logic [1:0][0:0] is_page;
    logic            valid;
    logic            pad;
  } [1:0] tq;
  assign tq = din;
  for (genvar gx = 1; gx < 3; gx++) begin : g_x
    assign o_pm[gx] = tq[gx-1].is_page[1][0];
  end
endmodule
