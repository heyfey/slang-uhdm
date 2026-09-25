// § constPathBaseAnyKind146
interface bus_if #(parameter int W = 8);
  logic [W-1:0] d;
endinterface
module m(bus_if b, output logic o);
  case (b.W)
    8: begin : g8 assign o = 1'b1; end
    default: begin : gd assign o = 1'b0; end
  endcase
endmodule
module top(output logic o);
  bus_if #(.W(8)) s();
  m u(.b(s), .o(o));
endmodule
