// v9 — the child READS the overridden fill parameter, so the claimed/cloned
// constant shows up in a cont_assign, an initial block and a port connection.
module leaf #(parameter bit [5:0] P = '0) (output logic [5:0] o, output logic [5:0] o2);
  assign o = P;
  assign o2 = P + 6'd1;
  localparam bit [5:0] L = P;
endmodule
module leaf1 #(parameter bit [5:0] P = '1) (output logic [5:0] o);
  assign o = P;
endmodule
module v9 (output logic [5:0] a, b, c, d);
  leaf  #('0) u0 (.o(a), .o2(b));
  leaf1 #('1) u1 (.o(c));
  leaf  #('x) ux (.o(d), .o2());
endmodule
