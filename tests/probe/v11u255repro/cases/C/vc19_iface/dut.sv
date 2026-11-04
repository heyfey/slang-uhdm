// § defGenCfcThroughCondSel255 (an interface-port path under a ?: and in a select index)
interface bus_if; logic [3:0] sel [2]; logic [1:0] en; modport m(input sel, en); endinterface
module dut (bus_if.m b, input logic [15:0] d, output logic [1:0] o);
  for (genvar k = 0; k < 2; k++) begin : g
    assign o[k] = b.en[k] ? d[b.sel[k]] : 1'b0;
  end
endmodule
module top;
  bus_if bi();
  logic [1:0] o;
  dut u (.b(bi), .d(16'h0), .o(o));
endmodule
