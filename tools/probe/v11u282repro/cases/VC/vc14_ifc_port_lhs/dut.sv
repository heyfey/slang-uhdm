// § genCaSelBoundNestedOwner282
interface ifc; logic [1:0] s; endinterface
module top #(parameter int P = 2) (input logic [7:0] b, ifc i);
  if (1) begin : gi
    assign i.s = b[P +: 2] | 2'd0;
  end
endmodule
module wrap(input logic [7:0] b, output logic [1:0] z); ifc ii(); top u(.b(b), .i(ii)); assign z = ii.s; endmodule
