// § escNameSpanSites295
module child (input logic a, output logic o); assign o = a; endmodule
module dut (input logic [1:0] a, output logic [1:0] o);
  for (genvar i = 0; i < 2; i++) begin : g
    child \u.g (.a(a[i]), .o(o[i]));
  end
endmodule
