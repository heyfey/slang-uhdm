module dut (output logic [31:0] o);
  typedef logic signed [31:0] imm_t;
  function automatic imm_t sext(logic [11:0] x); sext = imm_t'($signed(x)); endfunction
  localparam logic [11:0] K = 12'hFFF;
  assign o = sext(K);
endmodule
