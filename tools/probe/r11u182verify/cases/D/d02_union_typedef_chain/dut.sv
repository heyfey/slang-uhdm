// § castUnionCloneFile171
module dut (input logic [7:0] i, output logic [3:0] o, p);
  pu::v_t x;
  pu::u_t y;
  assign x = pu::v_t'(i);
  assign y = pu::u_t'(i);
  assign o = x.n[1];
  assign p = y.n[0];
endmodule
