// § tpAnonStructLastParamUser167 § tpAnonStructCopySpanAtKeyword167 — the type named by a task formal and a value parameter
module top (input logic clk, output logic [3:0] b);
  localparam type it_t = struct packed {
    logic [3:0] x;
  };
  localparam it_t I = '{x: 4'd9};
  task automatic put(input it_t v, output logic [3:0] o);
    o = v.x;
  endtask
  always_ff @(posedge clk) put(I, b);
endmodule
