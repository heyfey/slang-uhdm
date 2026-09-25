// § hpSelRoute157
typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
interface ifc; s_t st; logic [15:0] v; logic [3:0] m [16]; endinterface
module sub (ifc bus, input logic clk, output logic [3:0] q);
  always_ff @(posedge clk) begin
    bus.m[bus.st.a] <= bus.v[bus.st.b +: 4];
    q <= bus.st.a ? bus.m[bus.st.b] : '0;
  end
endmodule
module top (input logic clk, output logic [3:0] q); ifc b(); sub u(.bus(b), .clk(clk), .q(q)); endmodule
