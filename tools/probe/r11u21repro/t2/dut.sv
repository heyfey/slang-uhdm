// t2 — the base is a LITERAL (assignment-pattern) struct parameter, NOT
// function-built: does a member read still reduce to the member's slice?
package pk;
  typedef struct packed {
    int unsigned sidWidth;
    int unsigned dataWidth;
  } user_cfg_t;
  typedef struct packed {
    user_cfg_t   u;
    int unsigned derived;
  } cfg_t;
  localparam cfg_t LIT = '{u: '{sidWidth: 3, dataWidth: 32}, derived: 64};
endpackage

module dut #(
    parameter  pk::cfg_t P = pk::LIT,                          // package literal
    parameter  pk::cfg_t Q = '{u:'{5,16}, derived:7}           // written HERE
) (
    output logic o
);
  localparam int A1 = P.derived;
  localparam int A2 = P.u.sidWidth;
  localparam int B1 = Q.derived;
  localparam int B2 = Q.u.dataWidth;
  assign o = ^{A1[0], A2[0], B1[0], B2[0]};
endmodule
