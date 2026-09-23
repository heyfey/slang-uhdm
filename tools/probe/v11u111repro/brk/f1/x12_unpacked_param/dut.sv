package q;
  typedef logic [3:0] mask_t;
endpackage
module sub #(parameter q::mask_t M [2] = '{4'h1, 4'h2}) (output logic [3:0] o);
  assign o = M[0] ^ M[1];
endmodule
module dut (output logic [3:0] o);
  sub u (.o(o));
endmodule
