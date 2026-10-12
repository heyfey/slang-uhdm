// § caDlyParamLitRhsFresh301
module sub #(parameter int D = 4) (output logic [7:0] o);
  assign #D o = 8'b1010_0101;
endmodule
module dut (output logic [7:0] o, p, q);
  sub u_a (.o(o));
  sub #(.D(1)) u_b (.o(p));
  sub #(.D(2)) u_c (.o(q));
endmodule
