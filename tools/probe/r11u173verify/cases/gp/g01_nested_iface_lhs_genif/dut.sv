// § defGenPathSel161 — gen-if target through a nested interface instance (interface inside interface)
interface in_if;
  logic [3:0] x;
endinterface
interface out_if;
  in_if sub();
  logic y;
endinterface
module top(input logic [3:0] a, output logic [3:0] o);
  out_if b();
  if (1) begin : g
    assign b.sub.x = a;
  end
  assign o = b.sub.x;
endmodule
