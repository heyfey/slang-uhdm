// § genIfaceConnGenScopeName313
interface ifd (input logic [1:0] d);
  logic [7:0] sig;
endinterface
module top (output logic [1:0] o);
  for (genvar i = 0; i < 2; i++) begin : g
    ifd u (.d(i));
    assign o[i] = u.sig[0];
  end
endmodule
