// § signCastSysCallLhsTs212 — verifier: a signing cast onto a variable typed by a type parameter
module c #(parameter type T = logic [3:0]) (input logic [3:0] i, output T o);
  T v;
  assign v = signed'(i);
  assign o = v;
endmodule
module dut (input logic [3:0] i, output logic [3:0] o, output logic [7:0] o2);
  c u (.i(i), .o(o));
  c #(.T(logic signed [7:0])) w (.i(i), .o(o2));
endmodule
