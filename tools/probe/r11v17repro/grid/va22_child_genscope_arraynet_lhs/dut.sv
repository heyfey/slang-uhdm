// LAW 1 inside a CHILD instance's generate scope.
module ch(input logic [31:0] i, output logic [31:0] o);
  wire [31:0] arr[2];
  if (1) begin : gb
    assign arr = '{i, i};
  end
  assign o = arr[0];
endmodule
module top(input logic [31:0] a, output logic [31:0] o);
  ch u_c(.i(a), .o(o));
endmodule
