module dut #(parameter int unsigned DmBaseAddr = 32'h1A110000, parameter int unsigned DmAddrMask = 32'h00000FFF) (input logic [33:0] pmp_req_addr_i [3], output logic [2:0] o);
  for (genvar c = 0; c < 3; c++) begin : g_a
    assign o[c] = ((pmp_req_addr_i[c][31:0] & ~DmAddrMask) == DmBaseAddr);
  end
endmodule
