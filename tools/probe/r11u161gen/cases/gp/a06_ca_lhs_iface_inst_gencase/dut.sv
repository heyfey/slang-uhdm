// r11u161 gen path: cont-assign LHS inside a gen-case item, interface-instance member (SEL)
interface bus_if;
  logic [3:0] d;
endinterface
module top #(parameter int M = 1) (input logic [3:0] a, output logic [3:0] o);
  bus_if b ();
  case (M)
    0: begin : c0
      assign b.d = a;
    end
    default: begin : c1
      assign b.d = ~a;
    end
  endcase
  assign o = b.d;
endmodule
