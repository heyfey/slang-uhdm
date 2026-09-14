package pk;
  typedef enum integer { PNone, PBal } p_e;
endpackage
package sp;
  typedef struct packed { logic [31:0] m; } st_t;
endpackage
module top import pk::*; import sp::*; #(parameter p_e P = PNone)
  (input logic [31:0] a, input logic [4:0] s, output st_t o2);
  if (1) begin : gb
    assign o2.m = (P != PNone) ? ~(32'hffff_ffff << s) : '0;
  end
endmodule
