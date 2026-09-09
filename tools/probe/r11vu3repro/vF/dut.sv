package pf;
  typedef struct packed { logic [3:0] g; logic [3:0] h; } sf_t;
endpackage
interface ifc();
  parameter int W = 0;
  logic [7:0] d;
endinterface
program prg();
  parameter int W = 0;
  initial $display("%0d", W);
endprogram
module leaf(output logic [3:0] o); parameter int P = 0; assign o = P[3:0]; endmodule
module top(output logic [3:0] o1, output logic [3:0] o2);
  parameter pf::sf_t C = 8'b10100101;
  ifc #(.W(C.g)) u_if ();
  prg #(.W(C.h)) u_pr ();
  generate
    if (1) begin : gb
      leaf #(.P(C.g)) u_gl (.o(o1));
    end
  endgenerate
  leaf u_dp (.o(o2));
  defparam u_dp.P = C.h;
endmodule
