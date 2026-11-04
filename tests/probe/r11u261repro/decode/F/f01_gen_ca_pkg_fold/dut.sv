// § stampFoldedPkgParamTs (decode only, ground A: Earlgrey #472295 onward, folded package parameter ts refs in elaborated generate scopes named after the scope or select where golden names the instance)
package fp;
  parameter int AW = 16;
  parameter int PW = 8;
  parameter int WW = 7;
endpackage
module rd import fp::*; (input logic [AW-1:0] addr_i, input logic e, output logic [1:0] hz);
  typedef struct packed { logic [AW-1:0] addr; logic v; } buf_t;
  buf_t read_buf [2];
  assign read_buf[0] = '0;
  assign read_buf[1] = '0;
  for (genvar i = 0; i < 2; i++) begin : gen_m
    assign hz[i] = e & read_buf[i].addr[WW +: PW] == addr_i[AW-1:AW-PW];
  end
endmodule
module top;
  logic [15:0] a; logic e; logic [1:0] h;
  rd u (.addr_i(a), .e(e), .hz(h));
endmodule
