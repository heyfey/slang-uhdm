// r11u161 gen path: gen-case condition and item reading interface-port parameters (SEL)
interface bus_if #(parameter int M = 1, parameter int K = 1);
  logic [3:0] d;
endinterface
module child (bus_if sub, output logic [3:0] o);
  case (sub.M)
    sub.K: begin : c0
      assign o = sub.d;
    end
    default: begin : c1
      assign o = '0;
    end
  endcase
endmodule
module top (input logic [3:0] s, output logic [3:0] o);
  bus_if b ();
  assign b.d = s;
  child c (.sub(b), .o(o));
endmodule
