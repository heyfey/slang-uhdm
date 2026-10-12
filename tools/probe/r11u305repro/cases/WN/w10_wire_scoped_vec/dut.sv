// § wireScopedTdEndAtType305
package pk;
  typedef logic [3:0] v_t;
endpackage
module top (input pk::v_t t, output logic [3:0] o);
  wire pk::v_t sn;
  assign sn = t;
  assign o = sn;
endmodule
