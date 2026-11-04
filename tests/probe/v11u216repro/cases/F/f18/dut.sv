// § ndaSizeQueryFold216 — $size in an interface net initializer and in a generate-scope net initializer, instance twice
interface ifc #(parameter int W = 4);
  logic [W-1:0] d;
  wire [7:0] n = $size(d);
endinterface
module dut (output logic [7:0] o);
  ifc #(3) u();
  ifc #(5) v();
  if (1) begin : g
    logic [2:0] q;
    wire [7:0] m = $size(q);
  end
  assign o = u.n ^ v.n ^ g.m;
endmodule
