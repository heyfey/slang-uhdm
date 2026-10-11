// § genCaSelBoundImplicitLhs282
module sub #(parameter int W = 3) (input logic [7:0] a, output logic o);
  if (1) begin : gf
    assign imp = ^a[W:0];
  end
  assign o = gf.imp;
endmodule
module top(input logic [7:0] a, output logic o); sub u(.a(a), .o(o)); endmodule
