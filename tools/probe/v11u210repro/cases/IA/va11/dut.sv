// § elabIfArrIdxChainName205 — va11 (v11u210 break probe): the literal-driven interface-array targets in a leaf module instantiated at depths 1, 2 and 3 (two instances at the top)
interface bi;
  logic w;
endinterface
module leaf(output logic o);
  bi b[2]();
  for (genvar i = 0; i < 2; i++) begin : g
    assign b[i].w = 1'b1;
  end
  assign o = b[0].w;
endmodule
module mid2(output logic o);
  leaf l(.o(o));
endmodule
module mid1(output logic o);
  mid2 m(.o(o));
endmodule
module dut(output logic o, output logic p, output logic q);
  leaf l0(.o(o));
  mid2 m2(.o(p));
  mid1 m1(.o(q));
endmodule
