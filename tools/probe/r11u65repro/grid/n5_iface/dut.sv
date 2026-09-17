// r11u65 n5 — INTERFACE NETS ARE A SEPARATE CELL (OPS caution (d)), and the
// INSTANTIATED / UNINSTANTIATED split is r10v225's R1.  Two interfaces with the
// same declarations, one instantiated and one not.
interface ifc_i #(parameter int unsigned N = 2, parameter int unsigned D = 4) ();
  typedef logic [N-1:0] a_t [D];
  typedef logic [N-1:0] v_t;
  typedef bit   [N-1:0] b_t [D];
  a_t ia;            // unpacked-array typedef, INSTANTIATED interface
  v_t iv;            // packed typedef
  b_t ib;            // bit element (control)
  logic [N-1:0] ip [D];   // declaration unpacked dim, no typedef
endinterface

interface ifc_u #(parameter int unsigned N = 2, parameter int unsigned D = 4) ();
  typedef logic [N-1:0] a_t [D];
  typedef logic [N-1:0] v_t;
  a_t ua;            // the same two, UNINSTANTIATED interface
  v_t uv;
endinterface

module dut (output logic [1:0] o);
  ifc_i u();
  assign o = u.ia[0] | u.iv | {2{u.ib[0][0]}} | u.ip[0];
endmodule
