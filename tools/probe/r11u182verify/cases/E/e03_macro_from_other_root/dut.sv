// § tsMemberRootFile171
module dut (input logic [7:0] i, output logic [3:0] o);
  typedef struct packed {
    `MEMBERS
  } s_t;
  s_t x;
  assign x = i;
  assign o = x.b;
endmodule
