// § constPathBaseAnyKind146
interface bus_if #(parameter int W = 8);
  logic [W-1:0] d;
  modport mp(input d);
endinterface
module m(bus_if.mp b, input logic [b.W-1:0] din, output logic [7:0] o);
  assign o = din;
endmodule
module top(input logic [7:0] i, output logic [7:0] o);
  bus_if #(.W(8)) s();
  m u(.b(s), .din(i), .o(o));
endmodule
