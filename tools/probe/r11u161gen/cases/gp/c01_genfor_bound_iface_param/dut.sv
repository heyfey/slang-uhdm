// r11u161 gen path: gen-for bound reading an interface-port parameter (SEL)
interface bus_if #(parameter int N = 4);
  logic [3:0] d;
  logic [3:0] q;
endinterface
module child (bus_if sub);
  for (genvar i = 0; i < sub.N; i++) begin : g
    assign sub.q[i] = sub.d[i];
  end
endmodule
module top (input logic [3:0] s, output logic [3:0] o);
  bus_if b ();
  assign b.d = s;
  assign o = b.q;
  child c (.sub(b));
endmodule
