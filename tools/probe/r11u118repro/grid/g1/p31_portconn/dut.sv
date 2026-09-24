package mask_pkg;
  localparam logic [63:0] MASK = 64'hDEADBEEF_12345678;
  localparam logic [1:0][7:0] ARR = 16'hA55A;
  typedef struct packed { logic [7:0] f; logic [7:0] g; } s_t;
  localparam s_t CFG = '{f: 8'h3C, g: 8'hC3};
endpackage
module sub (input logic [7:0] i, output logic [7:0] o);
  assign o = i;
endmodule
module top (output logic [7:0] o);
  sub u (.i(mask_pkg::MASK[7:0]), .o(o));
endmodule
