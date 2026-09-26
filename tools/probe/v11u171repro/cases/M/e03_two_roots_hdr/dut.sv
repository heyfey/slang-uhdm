// § tsMemberRootFile171
module dut(input logic [7:0] i, output logic [7:0] o);
  pk::s_t s;
  assign s = i;
  assign o = s;
endmodule
