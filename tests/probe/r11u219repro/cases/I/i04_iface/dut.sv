// § defGenTargetIpsSelArm219 — a spaced indexed part-select target on an interface instance member inside a case generate
interface bus_if;
  logic [7:0] data;
  logic       v;
endinterface
module top #(parameter int M = 1) (input logic [3:0] i, output logic [7:0] o);
  bus_if bus();
  assign bus.v = 1'b1;
  assign bus.data[1:0] = 2'b0;
  assign bus.data[7:6] = 2'b0;
  case (M)
    1: begin : c1
      assign bus.data[5 -: 2] = i[1:0];
      assign bus.data[2 +: 2] = i[3:2];
    end
    default: begin : cd
      assign bus.data[5:2] = i;
    end
  endcase
  assign o = bus.data;
endmodule
