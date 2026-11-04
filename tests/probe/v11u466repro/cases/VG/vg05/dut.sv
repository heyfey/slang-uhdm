// § genIfcViewSharesParamAssigns466
interface bif #(parameter int W = 4);
  logic [W-1:0] d;
endinterface
module s(interface a, interface b, output logic o);
  assign o = a.d[0] ^ b.d[0];
endmodule
module top(output logic o);
  bif #(.W(6)) M();
  s dut(.a(M), .b(M), .o(o));
endmodule
