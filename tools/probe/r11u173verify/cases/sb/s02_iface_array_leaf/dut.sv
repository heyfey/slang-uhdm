// § defGenSelBaseLeafAtIndex164 — gen-for target through an interface array selected by the genvar, literal-selected leaf
interface d_if;
  logic [1:0] d;
endinterface
module top(output logic [3:0] o);
  d_if b [2] ();
  for (genvar i = 0; i < 2; i++) begin : g
    assign b[i].d[0] = 1'b1;
    assign b[i].d[1] = 1'b0;
  end
  assign o = {b[1].d, b[0].d};
endmodule
