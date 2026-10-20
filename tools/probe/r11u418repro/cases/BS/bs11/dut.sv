// § tdMoveRenamesBitSelect418
interface ifc #(parameter D = 2, parameter int P[D:0] = '{5, 4, 0}) ();
  typedef struct packed { logic [P[D]-1:0] cord; } h_s;
  for (genvar i = 0; i < 2; i++) begin : g
    h_s hdr;
    assign hdr = '0;
  end
endinterface
module top; endmodule
