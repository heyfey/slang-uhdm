module child #(parameter type id_t = logic, localparam type rt_t = id_t [3:0]) (input rt_t a, output rt_t o);
  rt_t r;
  assign r = a;
  assign o = r;
endmodule
module dut (input logic [7:0] a, output logic [7:0] o);
  for (genvar i = 0; i < 2; i++) begin : g
    child #(.id_t(logic [i:0])) u (.a(a[4*(i+1)-1:0]), .o());
  end
  assign o = a;
endmodule
