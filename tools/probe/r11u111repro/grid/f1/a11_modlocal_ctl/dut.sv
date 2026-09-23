module sub #(parameter int W = 3) (output logic [2:0] o);
  typedef logic [W-1:0] mask_t;
  localparam mask_t L = 3'b101;
  assign o = L;
endmodule
module dut (output logic [2:0] o);
  sub #(.W(3)) u (.o(o));
endmodule
