// § constPathBaseAnyKind146
interface bus_if #(parameter int W = 4);
  logic [W-1:0] d;
endinterface
module m(bus_if b, output logic [3:0] o);
  for (genvar k = 0; k < b.W; k++) begin : gk
    assign o[k] = b.d[k];
  end
endmodule
module top(output logic [3:0] o);
  bus_if #(.W(4)) s();
  m u(.b(s), .o(o));
endmodule
