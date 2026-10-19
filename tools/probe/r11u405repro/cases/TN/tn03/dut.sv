// § tpCastBeforeTpListed405
module demux #(
  parameter int WIDTH = 8,
  parameter type DATA_TYPE = logic [WIDTH-1:0],
  parameter DATA_TYPE DEFAULT = DATA_TYPE'(0)
)(input DATA_TYPE i, output DATA_TYPE o);
  assign o = i | DEFAULT;
endmodule
module top(input logic [3:0] a, output logic [3:0] b);
  demux #(.WIDTH(4)) u(a, b);
endmodule
