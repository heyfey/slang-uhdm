// § genCaSelBoundImplicitLhs282
module sub #(parameter int W = 3) (input logic [7:0] a, output logic o);
  for (genvar i = 0; i < 2; i++) begin : gf
    assign imp = ^a[W:0];
  end
  assign o = gf[0].imp;
endmodule
module top(input logic [7:0] a, output logic o); sub u(.a(a), .o(o)); endmodule
