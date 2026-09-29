// § hpVarSelRangeIdxNamesByPath220 — a path's trailing var_select with three selects ending in a range, genvar and cast indices, in a two-level generate
module top(input logic [63:0] din, output logic [1:0] o [2][2]);
  struct packed {
    logic [1:0][1:0][3:0] m;
    logic [31:0]          pad;
  } [1:0] tq;
  assign tq = {din, din};
  for (genvar gi = 0; gi < 2; gi++) begin : g_i
    for (genvar gx = 0; gx < 2; gx++) begin : g_x
      assign o[gi][gx] = tq[gi].m[int'(gx)][gi][1:0];
    end
  end
endmodule
