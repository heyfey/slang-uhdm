interface ifc;
  logic [1:0] we;
  if (1) begin : gb
    assign we = '{default: '0};
  end
endinterface
module top(input logic [31:0] a, output logic [1:0] o);
  ifc i();
  assign o = i.we;
endmodule
