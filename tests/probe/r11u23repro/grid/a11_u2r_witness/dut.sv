module w11 #(parameter int NumIn = 4, parameter bit ExtPrio = 1'b0)
  (input logic clk_i, input logic rst_ni, input logic flush_i,
   input logic [NumIn-1:0] req_i, input logic gnt_i,
   input logic [$clog2(NumIn)-1:0] rr_i, output logic [$clog2(NumIn)-1:0] rr_o);
  localparam int IdxW = $clog2(NumIn);
  if (NumIn > 1) begin : gen_arbiter
    logic [IdxW-1:0] rr_q;
    if (ExtPrio) begin : gen_ext_rr
      assign rr_q = rr_i;
    end else begin : gen_int_rr
      logic [IdxW-1:0] rr_d;
      assign rr_d = (gnt_i && |req_i) ?
                    ((rr_q == IdxW'(NumIn-1)) ? '0 : rr_q + 1'b1) : rr_q;
      always_ff @(posedge clk_i or negedge rst_ni) begin : p_rr_regs
        if (!rst_ni)      rr_q <= '0;
        else if (flush_i) rr_q <= '0;
        else              rr_q <= rr_d;
      end
    end
    assign rr_o = rr_q;
  end
endmodule
