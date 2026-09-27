// § memberSelParenIdxSpan184: an interface port member select and a modport rvalue with parenthesized indices
interface bus_if;
  logic [7:0] data;
  logic [3:0][1:0] q;
  modport mp (input data, input q);
endinterface
module sub(bus_if.mp b, input logic [2:0] k, output logic y, output logic [1:0] w);
  assign y = b.data[(k)];
  always_comb w = b.q[(k)];
endmodule
module top(input logic [2:0] k, output logic y, output logic [1:0] w);
  bus_if b ();
  sub u (.b(b), .k(k), .y(y), .w(w));
endmodule
