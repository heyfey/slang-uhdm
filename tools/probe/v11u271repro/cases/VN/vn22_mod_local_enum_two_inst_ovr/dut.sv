// § ndaImpEnumConstUnlocated271
module sub #(parameter int W = 4) (output logic [W-1:0] o);
  typedef enum logic [3:0] { LA = 4'hA, LB = 4'h5 } l_t;
  wire [W-1:0] w_w = LB;
  wire [3:0] w_x = LA;
  assign o = w_w ^ w_x;
endmodule
module dut (output logic [11:0] o);
  sub u_a (.o(o[3:0]));
  sub #(.W(8)) u_b (.o(o[11:4]));
endmodule
