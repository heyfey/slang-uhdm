// § ifaceHcSelNamedByInst313
module leaf (input logic a, output logic o);
  assign o = a;
endmodule
module top (input logic [1:0] ck, output logic [1:0] o);
  leaf l (.a(ck[1]), .o(o[0]));
  if (1) begin : g
    leaf m (.a(ck[0]), .o(o[1]));
  end
endmodule
