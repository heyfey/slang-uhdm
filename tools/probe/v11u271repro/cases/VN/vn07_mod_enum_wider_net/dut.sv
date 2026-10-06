// § ndaImpEnumConstUnlocated271
module sub (output logic [7:0] o);
  typedef enum logic [3:0] { LA = 4'hA, LB = 4'h5 } l_t;
  wire [7:0] w_w = LA;
  wire [1:0] w_n = LB;
  assign o = w_w ^ {6'b0, w_n};
endmodule
module dut (output logic [7:0] o);
  sub u_s (.o(o));
endmodule
