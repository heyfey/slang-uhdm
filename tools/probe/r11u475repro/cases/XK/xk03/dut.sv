// § caReduceLeavesOpKept475
module sub #(parameter logic [5:0] Q = 0) (output logic [5:0] o);
  assign o = Q;
endmodule
module top(output logic [5:0] y, output logic [5:0] z);
  parameter logic [5:0] PA = 6'd33;
  parameter logic [5:0] PB = 6'd5;
  wire [5:0] w = PA ^ PB;
  logic [5:0] v = PA ^ PB;
  sub #(.Q(PA ^ PB)) u(.o(y));
  assign z = w ^ v;
endmodule
