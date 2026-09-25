// r11u161 gen path: cont-assign LHS in a gen-if nested in a gen-for, interface-port member (SEL)
interface bus_if;
  logic [3:0] d;
  logic [3:0] q;
endinterface
module child (bus_if sub);
  for (genvar i = 0; i < 2; i++) begin : g
    if (i == 0) begin : h
      assign sub.q[i] = sub.d[i];
    end else begin : k
      assign sub.q[3:1] = sub.d[3:1];
    end
  end
endmodule
module top (input logic [3:0] s, output logic [3:0] o);
  bus_if b ();
  assign b.d = s;
  assign o = b.q;
  child c (.sub(b));
endmodule
