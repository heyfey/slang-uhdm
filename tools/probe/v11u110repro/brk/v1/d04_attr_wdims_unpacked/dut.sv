module child #(
    parameter type id_t = logic,
    localparam type rt_t = id_t [3:0]
) (input logic [15:0] a, output logic o);
  (* keep *) rt_t [1:0] x [2];
  assign x[0] = {a, a};
  assign x[1] = {a, a};
  assign o = ^x[0] ^ ^x[1];
endmodule
module dut(input logic [15:0] a, output logic o);
  child #(.id_t(logic [1:0])) u (.a(a), .o(o));
endmodule
