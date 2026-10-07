// § tpElabPortRebindSpanDiffers281
module child #(parameter type id_t = logic, localparam type rt_t = id_t [3:0]) (input rt_t a, output logic o);
  assign o = ^a;
endmodule
module dut #(parameter bit EN = 1) (input logic [3:0] a, output logic o);
  if (EN) begin : g
    child #(.id_t(logic)) u (.a(a), .o(o));
  end else begin : h
    assign o = 1'b0;
  end
endmodule
