// § hpVarSelRangeIdxNamesByPath220
module top(input logic [39:0] din, input logic [3:0] en, output logic [3:0] o_pm);
  struct packed {
    logic [15:0]     vpn;
    logic [1:0][0:0] is_page;
    logic            valid;
    logic            pad;
  } [1:0] tq;
  assign tq = din;
  for (genvar gi = 0; gi < 2; gi++) begin : g_i
    for (genvar gx = 1; gx < 3; gx++) begin : g_x
      assign o_pm[gi*2+gx-1] = &(tq[gi].is_page[2-gx][0:0] | (~en[0]));
    end
  end
endmodule
