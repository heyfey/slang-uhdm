// § genLoopDirectBoundPaConst262 (an interface's for-generate, its parameter a direct part-select bound)
interface ifc #(parameter int W = 3) ();
  logic [7:0] a;
  logic [3:0] o [2];
  for (genvar i = 0; i < 2; i++) begin : gf
    assign o[i] = a[W:0];
  end
endinterface
module top(output logic [3:0] o);
  ifc #(.W(2)) i();
  assign o = i.o[0];
endmodule
