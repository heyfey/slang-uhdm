// § ifaceHcSelNamedByInst313
module leaf (input logic a, output logic o);
  assign o = a;
endmodule
module top #(parameter P = 1) (input logic [1:0] ck, input logic [1:0] s, output logic [1:0] o);
  leaf l (.a(ck[P]), .o(o[0]));
  leaf m (.a(ck[s]), .o(o[1]));
endmodule
