// § ndaSizeFoldReach219 — a 2-D array's $size in an interface net, a for-generate net and a net of a narrower width (masked)
interface ifc;
  logic [7:0] mm [5][2];
  wire [7:0] iw = $size(mm, 2);
endinterface
module dut (output logic [1:0] o, output logic [7:0] og);
  ifc u();
  logic [3:0][2:0] pp [7];
  wire [1:0] nw = $size(pp);
  for (genvar k = 0; k < 2; k++) begin : g
    logic q [3][9];
    wire [7:0] gw = $size(q, 2);
  end
  assign o = nw;
  assign og = g[1].gw;
endmodule
