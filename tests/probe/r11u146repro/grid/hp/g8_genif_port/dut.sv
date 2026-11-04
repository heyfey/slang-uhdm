// § constPathBaseAnyKind146
interface bus_if #(parameter int W = 8);
  logic [W-1:0] d;
endinterface
module m(bus_if b, output logic [7:0] o);
  if (b.W == 8) begin : g
    assign o = 8'd1;
  end else begin : h
    assign o = 8'd2;
  end
endmodule
module top(output logic [7:0] o);
  bus_if #(.W(8)) s();
  m u(.b(s), .o(o));
endmodule
