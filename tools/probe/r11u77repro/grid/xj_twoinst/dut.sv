// r11v75 xj — LAW A ACROSS TWO INSTANCES.  `genScopeNets` is an EXPORTER
// member keyed on the slang symbol, and two identically-parameterised
// instances share one InstanceBodySymbol, so the map holds the LAST
// instance's object.  Pass 73's store (`netMap`) is handed in per instance;
// this one is not.  Does u1's cell bind u1's net?
module child (output logic [31:0] o);
  if (1) begin : L1
    wire  [31:0] n3;  assign n3 = 32'd7;
    logic [31:0] m3;
    if (1) begin : L2
      logic [31:0] n3;  assign n3 = 32'd4;   // NET namesake one scope out
      logic [31:0] m3;  assign m3 = 32'd3;   // VARIABLE namesake one scope out
    end
    assign m3 = 32'd8;
  end
  assign o = L1.L2.n3 ^ L1.L2.m3;
endmodule

module dut (output logic [31:0] o);
  logic [31:0] o1, o2;
  child u1 (.o(o1));
  child u2 (.o(o2));
  assign o = o1 ^ o2;
endmodule
