// § defNetTpPatNestedSig281
module child #(parameter type id_t = logic, localparam type rt_t = id_t [3:0]) (input logic clk, input logic [7:0] a, output logic [7:0] o);
  rt_t x [2];
  always_ff @(posedge clk) begin x[0] <= a; x[1] <= x[0]; end
  assign o = x[1];
endmodule
module dut(input logic clk, input logic [7:0] a, output logic [7:0] o);
  child #(.id_t(logic [1:0])) u (.clk(clk), .a(a), .o(o));
endmodule
