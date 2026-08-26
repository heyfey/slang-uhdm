// r10earl97 g2 -- OWNER GRID.  The same COMPUTED-default `int` cast width
// reached through every owner the census keys on: a port-list parameter, a
// body localparam, a parameter OVERRIDDEN from the instance, a parameter with
// a TYPE override, a package parameter, plus the non-cast owners the payload
// also lives on (typedef, function return, struct member, variable, port).
package p2o97;
  parameter int P_BASE = 8;
  parameter int P_PKG  = $clog2(P_BASE + 1);
endpackage
module top2o97;
  logic [31:0] o, o2;
  sub2o97 #(.P_PORT(9)) u_s(.o(o));
  sub2o97 #(.P_PORT(17)) u_s2(.o(o2));
  tpar2o97 #(.T(int)) u_t();
endmodule
module sub2o97 #(parameter int P_PORT = 3) (output logic [31:0] o);
  import p2o97::*;
  typedef int td_i97;
  typedef struct packed { int mi; logic [3:0] ml; } st97;
  localparam int P_BODY = $clog2(P_PORT + 1);
  localparam int P_OVR  = $clog2(P_PORT + 2);   // depends on the OVERRIDE
  int          v_i;
  td_i97       v_td;
  st97         v_st;
  logic [3:0]  m;
  function automatic int f97(int a);
    return a + 1;
  endfunction
  assign o = 32'(P_BODY'(m)) + 32'(P_OVR'(m)) + 32'(P_PKG'(m))
           + 32'(f97(1)) + 32'(v_i) + 32'(v_td) + 32'(v_st.mi);
endmodule
module tpar2o97 #(parameter type T = shortint) ();
  localparam int TW = $bits(T);
  logic [3:0]  m;
  logic [31:0] w;
  assign w = 32'(TW'(m));
endmodule
