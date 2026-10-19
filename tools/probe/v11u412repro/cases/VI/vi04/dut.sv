// § elabVarSysCallInit412
module sub(output logic [7:0] o);
  logic [7:0] v = $random();
  assign o = v;
endmodule
module top(output logic [7:0] o1, output logic [7:0] o2);
  sub a(.o(o1));
  sub b(.o(o2));
  logic [7:0] w = $urandom(5);
  int sz = $bits(w);
endmodule
