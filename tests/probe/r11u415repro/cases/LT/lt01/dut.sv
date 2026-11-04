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
if (valid_arb(.request(req), .valid(vld), .override(ovr))) begin
end
end
endmodule
