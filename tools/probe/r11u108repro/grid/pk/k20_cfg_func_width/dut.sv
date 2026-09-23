package q;
  localparam int unsigned NF = 3;
  typedef logic [0:NF-1] mask_t;
  function automatic int unsigned maxw(mask_t cfg);
    automatic int unsigned res = 0;
    for (int unsigned i = 0; i < NF; i++)
      if (cfg[i]) res = res + 1;
    return res;
  endfunction
endpackage
module sub #(parameter q::mask_t M = '0) (output logic [31:0] o);
  assign o = q::maxw(M);
endmodule
module dut (output logic [31:0] o);
  sub #(.M(3'b101)) u (.o(o));
endmodule
