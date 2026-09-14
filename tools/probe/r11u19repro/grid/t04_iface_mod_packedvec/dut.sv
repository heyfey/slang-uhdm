interface ifc;
  logic [1:0] we;
  assign we = '{default: '0};
endinterface
module top(input logic [31:0] a, output logic [1:0] o);
  ifc i();
  assign o = i.we;
endmodule
