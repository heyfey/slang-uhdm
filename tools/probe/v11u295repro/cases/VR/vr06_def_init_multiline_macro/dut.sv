// § rawEndLineModel295
`define INIT \
  8'h3
module top(output logic [7:0] o);
  logic [7:0] a = `INIT;
  assign o = a;
endmodule
