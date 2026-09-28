// § modGenericClassListed196 § modGenericHandleBare196: handles of a module-local generic in an if-generate block and a for-generate block
module sub #(parameter int N = 2) ();
  class box #(type E = int);
    E v;
  endclass
  if (N > 1) begin : g
    box #(byte) b;
  end
  for (genvar i = 0; i < N; i++) begin : f
    box #(logic [3:0]) c;
  end
endmodule
module top;
  sub u ();
endmodule
