// § ndaSysCallNetTs212 — verifier: a net initialized by $size and one by $left of an unpacked input array
module dut (input logic [3:0] i [5], output logic [7:0] o, output logic [7:0] o2);
  wire [7:0] s = $size(i);
  wire [7:0] l = $left(i);
  assign o = s;
  assign o2 = l;
endmodule
