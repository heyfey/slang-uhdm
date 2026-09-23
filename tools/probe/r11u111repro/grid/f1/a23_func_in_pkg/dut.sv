package p;
  localparam int N = 3;
  typedef logic [0:N-1] vn_t;
  function automatic int unsigned cnt(vn_t c);
    automatic int unsigned r = 0;
    for (int unsigned i = 0; i < N; i++) if (c[i]) r++;
    return r;
  endfunction
endpackage
module sub #(parameter p::vn_t M = '0) (output logic [31:0] o);
  assign o = p::cnt(M);
endmodule
module dut (output logic [31:0] o);
  sub #(.M(3'b101)) u (.o(o));
endmodule
