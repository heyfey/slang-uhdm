interface bif;
  logic [7:0] d;
  modport mst (input d);
endinterface
module m #(parameter bit P = 0)(bif.mst b);
  logic [7:0] arr[2];
  assign arr[0] = (P) ? 42 : b.d;
endmodule
module top;
  bif bi();
  m #(.P(1)) u_a(bi);
endmodule
