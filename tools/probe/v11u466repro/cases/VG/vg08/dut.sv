// § genIfcViewSharesParamAssigns466
interface bif #(parameter int W = 4);
  logic [W-1:0] d;
endinterface
module s(interface bus, output logic o);
  assign o = bus.d[0];
endmodule
module top(output logic o);
  bif #(.W(6)) M();
  for (genvar i = 0; i < 1; i++) begin : g
    s dut(.bus(M), .o(o));
  end
endmodule
