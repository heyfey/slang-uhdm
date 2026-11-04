// § elabParamRefSignedTsUnlocated264
interface bus_if #(parameter int W = 8);
  localparam int B = W;
  localparam int C = B;
  logic [C-1:0] d;
  modport m (input d);
endinterface
module cons (bus_if.m p, output logic [7:0] o);
  assign o = p.d;
endmodule
module top(output logic [7:0] o);
  bus_if #(.W(8)) b();
  bus_if q();
  cons c(.p(b), .o(o));
endmodule
