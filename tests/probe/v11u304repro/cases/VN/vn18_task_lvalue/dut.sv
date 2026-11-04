// § hpOpIdxNestedSelByPath304
module top (input logic [1:0] k, input logic clk, output logic [7:0] o);
  typedef struct packed {logic [7:0] fld; logic [7:0] g;} el_t;
  el_t [3:0] ea;
  task automatic wr(logic [1:0] kk, logic [7:0] v);
    ea[kk[0] + 1].fld = v;
  endtask
  always_ff @(posedge clk) begin wr(k, 8'h5); o <= ea[0].fld; end
endmodule
