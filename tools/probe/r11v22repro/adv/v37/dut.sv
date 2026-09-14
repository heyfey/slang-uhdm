module sub(output logic [31:0] so);
  if (1) begin : gb
    assign so = (1) ? 32'd7 : '0;
  end
endmodule
interface ifc;
  logic [31:0] w;
  sub u_sub(.so(w));
endinterface
module top(output logic [31:0] o);
  ifc u_if();
  assign o = u_if.w;
endmodule
