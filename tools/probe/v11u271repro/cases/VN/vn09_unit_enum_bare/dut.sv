// § ndaImpEnumConstUnlocated271
typedef enum logic [2:0] { UA = 3, UB = 5 } u_t;
localparam int UP = 7;
module sub (output logic [7:0] o);
  wire [2:0] w_u = UB;
  wire [7:0] w_p = UP;
  assign o = {w_u, w_p[4:0]};
endmodule
module dut (output logic [7:0] o);
  sub u_s (.o(o));
endmodule
