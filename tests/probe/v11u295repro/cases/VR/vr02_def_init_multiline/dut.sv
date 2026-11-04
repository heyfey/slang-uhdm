// § rawEndLineModel295
module top(output logic [7:0] o);
  logic [7:0] a = {4'h1,
    4'h2};
  assign o = a;
endmodule
