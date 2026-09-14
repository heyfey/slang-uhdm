interface ifc;
  logic [31:0] w;
  if (1) begin : gb
    assign w = (1) ? 32'd7 : '0;
  end
endinterface
module top(output logic [31:0] o);
  ifc u_if();
  assign o = u_if.w;
endmodule
