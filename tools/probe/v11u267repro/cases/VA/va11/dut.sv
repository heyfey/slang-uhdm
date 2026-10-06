// § caFoldDelayRefKeepsUnparented267v
package fp;
  localparam int AllPagesW = 9;
  localparam int Dly = 1;
  typedef struct packed { logic [8:0] q; } fld_t;
  typedef struct packed { fld_t base; fld_t size; } cfg_t;
endpackage
module fc import fp::*; (output cfg_t [1:0] o);
  cfg_t [1:0] r;
  assign #Dly r[1].size.q = {AllPagesW{1'b1}};
  assign #(fp::Dly) r[0].size.q = {AllPagesW{1'b0}};
  assign r[1].base.q = '0;
  assign r[0].base.q = '1;
  assign o = r;
endmodule
module top(output fp::cfg_t [1:0] o);
  fc u_fc(.o(o));
endmodule
