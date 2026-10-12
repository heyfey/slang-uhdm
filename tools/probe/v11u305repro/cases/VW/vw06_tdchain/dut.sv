// § wireScopedTdEndAtType305
package pb;
  typedef struct packed { logic [2:0] a; logic [2:0] b; } base_t;
endpackage
package pk;
  typedef pb::base_t sa_t;
endpackage
module top (input pk::sa_t t, output logic [2:0] o);
  wire pk::sa_t sn;
  assign sn = t;
  assign o = sn.a;
endmodule
