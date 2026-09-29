// § ndaSizeFoldReach219 — $size of a two-dimensional unpacked array in a generate-scope net declaration and in an interface
interface ifc;
  logic [3:0] mm [3][2];
  wire [7:0] n = $size(mm);
endinterface
module top #(parameter bit G = 1) (output logic [7:0] o, output logic [7:0] o2);
  ifc u();
  logic [1:0] m [5][3];
  if (G) begin : g
    wire [2:0] w = $size(m);
    assign o = 8'(w);
  end
  assign o2 = u.n;
endmodule
