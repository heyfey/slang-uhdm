// § wireScopedTdEndAtType305
package pk;
  typedef enum logic [1:0] {A, B, C} e_t;
endpackage
module top (input pk::e_t t, output logic [1:0] o);
  wire pk::e_t sn;
  assign sn = t;
  assign o = sn;
endmodule
