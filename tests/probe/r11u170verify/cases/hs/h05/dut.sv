// § hpSelRoute157
typedef struct packed { logic [3:0] a; logic [3:0] b; logic clk; logic rdy; } s_t;
typedef struct packed { int W; int D; } cfg_t;
module top #(parameter cfg_t Cfg = '{W: 8, D: 4}) (input s_t st, input logic [3:0] x, output logic [7:0] q);
  localparam int BW = $bits(st.a);
  logic [Cfg.W-1:0] w;
  logic [BW-1:0] z;
  always @(posedge st.clk) begin
    case (x)
      st.a: q <= {Cfg.D{1'b1}};
      st.b: q <= 8'(x inside {st.a, st.b});
      default: q <= '0;
    endcase
  end
  initial wait (st.rdy) z = st.a;
endmodule
