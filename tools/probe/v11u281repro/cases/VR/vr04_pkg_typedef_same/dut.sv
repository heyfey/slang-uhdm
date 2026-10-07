// § tpRebindSpanDiffers281
package pk; typedef logic e_t; endpackage
module child #(parameter type id_t = pk::e_t, localparam type rt_t = id_t [3:0]) (input rt_t a, output logic o);
  assign o = ^a;
endmodule
module dut(input logic [3:0] a, output logic o);
  child #(.id_t(pk::e_t)) u (.a(a), .o(o));
endmodule
