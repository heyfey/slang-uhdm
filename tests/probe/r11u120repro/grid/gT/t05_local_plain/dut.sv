module child #(parameter int W = 4, localparam type w_t = logic [7:0]) (input w_t a, output logic [W-1:0] b);
  assign b = a[W-1:0];
endmodule
module dut (input logic [7:0] a, output logic [2:0] b);
  child #(.W(3)) u (.a(a), .b(b));
endmodule
