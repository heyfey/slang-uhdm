// § ndaSysCallNetTs212 — a net initializer that is $unsigned of a signed input, in an interface
interface bi (input logic signed [9:0] i);
  wire [6:0] v = $unsigned(i[6:0]);
endinterface
module dut (input logic signed [9:0] i, output logic [6:0] o);
  bi b (.i(i));
  assign o = b.v;
endmodule
