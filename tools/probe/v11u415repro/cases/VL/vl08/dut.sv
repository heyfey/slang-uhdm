// § pkgLetCallFuncCall415
package pex;
  let valid_arb(request, valid, override) = |(request & valid) || override;
endpackage
module top;
  import pex::*;
  wire [1:0] req;
  wire [1:0] vld;
  logic ovr;
  initial begin
    if (valid_arb(.override(ovr), .request(req), .valid(vld))) begin
    end
  end
endmodule
