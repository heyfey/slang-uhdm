// § genCaReplWholeFold78 (decode only, ground B's ModuleEmit: Earlgrey #600811 / #530951) (c02 at instance depth 1)
module m #(parameter int Width = 32, parameter bit EnableECC = 0, parameter bit EnableParity = 0) (output logic [38:0] q);
  localparam int ParWidth = (EnableParity) ? Width/8 : (!EnableECC) ? 0 : 7;
  localparam int TotalWidth = Width + ParWidth;
  logic [TotalWidth-1:0] a_wmask_d;
  if (EnableParity == 0 && EnableECC) begin : gen_secded
    assign a_wmask_d = {TotalWidth{1'b1}};
  end
  assign q = a_wmask_d;
endmodule
module top(output logic [38:0] q);
  m #(.EnableECC(1)) i_prim (.*);
endmodule
