// § caSelLhsBareDecNoAdjust144
module sub #(parameter int W = 4) (output logic [W-1:0] o);
  assign o[W-1] = 1;
  assign o[W-2:0] = 3;
endmodule
module dut(output logic [5:0] o);
  sub #(.W(6)) u(.o(o));
endmodule
