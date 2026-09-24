// r10v68 arm v9b — IMPLICIT nets, bare `var`, 1-bit targets.  MEASUREMENT ONLY.
module v9b_imp68 (output logic [7:0] o);
  var         vv;
  logic       l1;
  wire        w1;
  logic [7:0] sink;
  for (genvar i = 5; i < 6; i++) begin : g
    if (i > 0) begin : b1
      assign imp_net = i;
      assign vv      = i;
      assign l1      = i;
      assign w1      = i;
      assign sink    = {7'b0, imp_net};
    end
  end
  assign o = sink ^ {5'b0, vv, l1, w1};
endmodule
