// § lpPaCopyBoundOwnerName145
module sub #(parameter int L = 2) (input logic [31:0] a, output logic [3:0] o);
  if (1) begin : g
    assign o = a[L+3:L];
  end
endmodule
module dut(input logic [31:0] a, output logic [3:0] o, output logic [3:0] p);
  sub #(.L(8)) u1(.a(a), .o(o));
  sub #(.L(12)) u2(.a(a), .o(p));
endmodule
