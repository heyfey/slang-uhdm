// § genCaReplCountInst282
interface ifc; logic [3:0] s; endinterface
module top #(parameter int W = 2) (input logic [7:0] e, ifc i);
  for (genvar g = 0; g < 1; g++) begin : gb
    assign i.s = {W{e[1:0]}};
  end
endmodule
module wrap(input logic [7:0] e, output logic [3:0] z); ifc ii(); top u(.e(e), .i(ii)); assign z = ii.s; endmodule
