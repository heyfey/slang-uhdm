// § tpElemPatAtUser152
interface bus_if #(
    parameter type id_t = logic [1:0],
    localparam type rt_t = id_t [3:0]
) (input rt_t r);
  logic o;
  assign o = ^r;
endinterface
module top(input logic [7:0] a, output logic o);
  bus_if b(.r(a));
  assign o = b.o;
endmodule
