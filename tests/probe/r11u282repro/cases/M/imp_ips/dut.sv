// § genCaSelBoundImplicitLhs282
module ctrl (input logic [7:0] a, output logic q);
  localparam int K = 2;
  for (genvar h = 0; h < 1; h++) begin : gf
    assign imp = a[K +: 2] == 2'b01;
  end
  assign q = gf[0].imp;
endmodule
module top(input logic [7:0] a, output logic q); ctrl u (.a(a), .q(q)); endmodule
