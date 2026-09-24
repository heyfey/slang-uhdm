package pk;
  typedef enum integer { PNone, PBal } p_e;
endpackage
package sp;
  typedef struct packed { logic [31:0] m; } st_t;
endpackage
module top import pk::*; import sp::*; #(parameter p_e P = PNone)
  (input st_t st, input logic [4:0] s, output logic [31:0] o2);
  if (1) begin : gb
    assign o2 = (P == PNone) ? st.m : '0;
  end
endmodule
