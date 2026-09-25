// r11u161 gen path: gen-for initial value and bound both interface-port parameters (SEL)
interface bus_if #(parameter int S = 1, parameter int N = 3);
  logic [3:0] d;
  logic [3:0] q;
endinterface
module child (bus_if sub);
  for (genvar i = sub.S; i <= sub.N; i = i + 1) begin : g
    assign sub.q[i] = sub.d[i];
  end
  assign sub.q[0] = 1'b0;
endmodule
module top (input logic [3:0] s, output logic [3:0] o);
  bus_if b ();
  assign b.d = s;
  assign o = b.q;
  child c (.sub(b));
endmodule
