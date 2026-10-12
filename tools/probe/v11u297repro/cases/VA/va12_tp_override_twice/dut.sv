// § varDeclInitMovesSharedTsEnd297
module c_m #(parameter type T = logic [3:0]) (output logic [7:0] o);
  var T x = '1;
  assign o = 8'(x);
endmodule
module dut(output logic [7:0] o, output logic [7:0] p, output logic [7:0] q);
  c_m #(.T(logic [7:0])) u1(.o(o));
  c_m u2(.o(p));
  c_m #(.T(logic [1:0])) u3(.o(q));
endmodule
